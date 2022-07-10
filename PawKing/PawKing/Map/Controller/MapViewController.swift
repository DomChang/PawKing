//
//  MapViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/14.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore
import FirebaseAuth
import Kingfisher

// swiftlint:disable file_length

class MapViewController: UIViewController {
    
    private let mapView = MKMapView()
    
    private var locationManager: CLLocationManager?
    
    private var locationAlertController: UIAlertController?
    
    private let userLocationButton = UIButton()
    
    private let trackButton = UIButton()
    
    private let saveTrackButton = UIButton()
    
    private let deleteTrackButton = UIButton()
    
    private let strangerButton = UIButton()
    
    private let notificationButton = UIButton()
    
    private let choosePetImageView = UIImageView()
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var strangersPet: [Pet] = [] {

        didSet {
            
            collectionView.reloadData()
        }
    }
    
    private var userStoredLocations: [CLLocation] = []
    
    private let mapManager = MapManager.shared
    
    private let userManager = UserManager.shared
    
    private let lottie = LottieWrapper.shared
    
    private var trackStartTime = Timestamp()
    
    private var user: User
    
    private var userPets: [Pet] = [] {
        didSet {
            if userPets.count == 0 {
                
                choosePetImageView.isHidden = true
            }
        }
    }
    
    private var userCurrentPet: Pet? {
        didSet {
//
//            if locationManager?.authorizationStatus == .denied ||
//                locationManager?.authorizationStatus == .restricted ||
//                locationManager?.authorizationStatus == .notDetermined ||
//                user.petsId.isEmpty {
//
//                trackButton.isHidden = true
//            } else {

//                trackButton.isHidden = !collectionView.isHidden
//            }
            
            if !trackButton.isSelected {
                
                choosePetImageView.isHidden = false
            } else {
                
                choosePetImageView.isHidden = true
            }
            styleCurrentPetButton()
        }
    }
    
    private var friendAnnotationsInfo: [String: UserAnnotation] = [:]
    
    private var friendLocations: [String: UserLocation] = [:] {
        didSet {
            updateAnnotation()
        }
    }
    
    private var listeners: [ListenerRegistration] = []
    
    private let noPetAlertController = UIAlertController(title: "No Pet",
                                                    message: "Cannot track with no pet, please add pet first!",
                                                    preferredStyle: .alert)
    
    init() {

        self.user = userManager.currentUser ?? userManager.guestUser
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setup()
        style()
        layout()
        setLocationAlert()
        setNoPetAlert()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        
        setLocationAlert()
        
        if Auth.auth().currentUser != nil {
            
            listenFriendsLocation()
            trackButton.isHidden = false
            notificationButton.isHidden = false
        } else {
            userCurrentPet = nil
            userPets = []
            listeners.forEach { $0.remove() }
            friendAnnotationsInfo = [:]
            friendLocations = [:]
            trackButton.isHidden = true
            choosePetImageView.isHidden = true
            notificationButton.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        didSelectUserLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
        
        listeners.forEach { $0.remove() }
        
        mapView.removeAnnotations(mapView.annotations)
        
        locationAlertController = nil
    }
    
    deinit {
        
        mapView.delegate = nil
    }
    
    @objc private func updateData() {
        
        if let user = UserManager.shared.currentUser {
            
            self.user = user
        }
        
        if Auth.auth().currentUser != nil {
            
            fetchUserPets(user: user)
            listenFriendsLocation()
            trackButton.isHidden = false
            notificationButton.isHidden = false

        } else {
            userCurrentPet = nil
            userPets = []
            listeners.forEach { $0.remove() }
            friendAnnotationsInfo = [:]
            friendLocations = [:]
            trackButton.isHidden = true
            choosePetImageView.isHidden = true
            notificationButton.isHidden = true
        }
    }
    
    private func setup() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateData),
                                               name: .updateUser,
                                               object: nil)
        
        choosePetImageView.isHidden = true
        
//        strangerButtonDisable()
        
//        strangerButtonEnable()
        
//        getUser()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.distanceFilter = 10
        locationManager?.checkLocationPermission()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.mapType = .mutedStandard
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "UserAnnotationView")
        
        choosePetImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapChoosePet)))
        
        choosePetImageView.isUserInteractionEnabled = true
        
        userLocationButton.addTarget(self, action: #selector(didSelectUserLocation), for: .touchUpInside)
        
        trackButton.addTarget(self, action: #selector(didTapRecordTrack), for: .touchUpInside)
        
        saveTrackButton.addTarget(self, action: #selector(didTapSaveTrack), for: .touchUpInside)
        
        deleteTrackButton.addTarget(self, action: #selector(didTapDeleteTrack), for: .touchUpInside)
        
        strangerButton.addTarget(self, action: #selector(didTapStrangerButton), for: .touchUpInside)
        
        notificationButton.addTarget(self, action: #selector(didTapNotificationButton), for: .touchUpInside)
        
        saveTrackButton.isHidden = true
        
        deleteTrackButton.isHidden = true
        
        collectionView.register(
            StrangerCardViewCell.self,
            forCellWithReuseIdentifier: StrangerCardViewCell.identifier)
        
        collectionView.register(
            NoStrangerCell.self,
            forCellWithReuseIdentifier: NoStrangerCell.identifier)
        
        collectionView.dataSource = self
        
        collectionView.delegate = self
        
        collectionView.isHidden = true
    }
    
    private func style() {
        
        mapView.layer.cornerRadius = 20
        mapView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        userLocationButton.setImage(UIImage.asset(.Icons_36px_UserLocate_Normal), for: .normal)
        userLocationButton.setImage(UIImage.asset(.Icons_36px_UserLocate_Selected), for: .selected)
        
        trackButton.setImage(UIImage.asset(.Icons_36px_RecordTrack_Normal), for: .normal)
        trackButton.setImage(UIImage.asset(.Icons_36px_RecordTrack_Selected), for: .selected)
        
        saveTrackButton.setTitle("儲存", for: .normal)
        saveTrackButton.backgroundColor = .Orange1
        saveTrackButton.layer.cornerRadius = 5
        
        deleteTrackButton.setTitle("放棄", for: .normal)
        deleteTrackButton.backgroundColor = .Gray1
        deleteTrackButton.layer.cornerRadius = 5
        
        styleCurrentPetButton()
        
        strangerButton.setImage(UIImage.asset(.Icons_60px_Stranger), for: .normal)
        
        notificationButton.setImage(UIImage.asset(.Icons_45px_Bell), for: .normal)
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
        
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func layout() {
        
        view.addSubview(mapView)
        view.addSubview(userLocationButton)
        view.addSubview(trackButton)
        view.addSubview(saveTrackButton)
        view.addSubview(deleteTrackButton)
        view.addSubview(strangerButton)
        view.addSubview(notificationButton)
        view.addSubview(collectionView)
        view.addSubview(choosePetImageView)
        
        mapView.anchor(top: view.topAnchor,
                       leading: view.leadingAnchor,
                       bottom: view.safeAreaLayoutGuide.bottomAnchor,
                       trailing: view.trailingAnchor)
        
        userLocationButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                  trailing: view.trailingAnchor,
                                  width: 36,
                                  height: 36,
                                  padding: UIEdgeInsets(top: 0, left: 0, bottom: 35, right: 35))
        
        trackButton.anchor(leading: view.leadingAnchor,
                           bottom: view.safeAreaLayoutGuide.bottomAnchor,
                           width: 36,
                           height: 36,
                           padding: UIEdgeInsets(top: 0, left: 35, bottom: 35, right: 0))
        
        deleteTrackButton.anchor(leading: view.leadingAnchor,
                           bottom: view.safeAreaLayoutGuide.bottomAnchor,
                           width: 60,
                           height: 36,
                           padding: UIEdgeInsets(top: 0, left: 35, bottom: 35, right: 0))
        
        saveTrackButton.anchor(leading: view.leadingAnchor,
                           bottom: view.safeAreaLayoutGuide.bottomAnchor,
                           width: 60,
                           height: 36,
                           padding: UIEdgeInsets(top: 0, left: 35, bottom: 35, right: 0))
        
        strangerButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                              leading: view.leadingAnchor,
                              width: 60,
                              height: 60,
                              padding: UIEdgeInsets(top: 60, left: 35, bottom: 0, right: 0))
        
        notificationButton.anchor(trailing: view.trailingAnchor,
                              centerY: strangerButton.centerYAnchor,
                              width: 45,
                              height: 45,
                              padding: UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 35))
        
        collectionView.anchor(top: strangerButton.bottomAnchor,
                              leading: view.leadingAnchor,
                              trailing: view.trailingAnchor,
                              height: 150,
                              padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        
        choosePetImageView.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                               centerX: view.centerXAnchor,
                               width: 100,
                               height: 100,
                               padding: UIEdgeInsets(top: 0, left: 0, bottom: 35, right: 0))
        
        strangerButton.setRadiusWithShadow()
        
        notificationButton.setRadiusWithShadow()
        
        userLocationButton.setRadiusWithShadow()
        
        trackButton.setRadiusWithShadow()

    }
    
//    private func getUser() {
//
//        guard let userId = Auth.auth().currentUser?.uid else { return }
//
//        userManager.fetchUserInfo(userId: userId) { [weak self] result in
//
//            switch result {
//
//            case .success(let user):
//
//                self?.user = user
//                self?.fetchUserPets(user: user)
//
//            case .failure(let error):
//
//                self?.lottie.showError(error)
//            }
//        }
//    }
    
    private func focusUserLocation() {
    
        let location = mapView.userLocation
        
        let region = MKCoordinateRegion(center: location.coordinate,
                                        span: .init(latitudeDelta: 0.01,
                                                    longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: false)
    }
    
    private func fetchStoredUserLocation(user: User) {
        
        userManager.fetchUserLocation(userId: user.id) { [weak self] result in
            switch result {
                
            case .success(let userLocation):
                
                self?.userPets.forEach({ pet in
                    
                    if pet.id == userLocation.currentPetId {
                        
                        self?.userCurrentPet = pet
                    }
                })
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    private func fetchUserPets(user: User) {
        
        lottie.startLoading()
        
        userManager.fetchPets(userId: user.id) { [weak self] result in
            
            switch result {
                
            case .success(let pets):
                
                self?.userPets = pets
                self?.fetchStoredUserLocation(user: user)
                self?.lottie.stopLoading()
                
            case .failure:
                
                self?.lottie.stopLoading()
            }
        }
    }
    
    private func styleCurrentPetButton() {
        
        choosePetImageView.makeRoundDoubleBorder(borderWidth: 2,
                                                 outterColor: .Orange1,
                                                 innerColor: .white)
        
        choosePetImageView.contentMode = .scaleAspectFill
        
        choosePetImageView.layer.masksToBounds = true
        
    if let userCurrentPet = userCurrentPet {
            
            let imageUrlSting = userCurrentPet.petImage
            
            choosePetImageView.kf.setImage(with: URL(string: imageUrlSting))
        } else {
            
            choosePetImageView.image = UIImage.asset(.Image_Placeholder)
        }
    }
    
    @objc func didSelectUserLocation() {
        
        userLocationButton.isSelected = true
        
        focusUserLocation()
        
        mapView.userTrackingMode = .follow
    }
    
    @objc func didTapRecordTrack() {
        
        guard !user.petsId.isEmpty else {
            
            present(noPetAlertController, animated: true)
            return
        }
        
        guard locationManager?.authorizationStatus != .denied &&
                locationManager?.authorizationStatus != .restricted &&
                locationManager?.authorizationStatus != .notDetermined else {
            
            if let locationAlertController = locationAlertController {
                present(locationAlertController, animated: true)
            }
            return
        }
        
        trackButton.isSelected = !trackButton.isSelected
        saveTrackButton.isHidden = trackButton.isSelected
        deleteTrackButton.isHidden = trackButton.isSelected
        
        userLocationButton.isHidden = !trackButton.isSelected
        
        choosePetImageView.isHidden = true
        
        mapView.isUserInteractionEnabled = trackButton.isSelected
        
        if trackButton.isSelected {
            
            locationManager?.startUpdatingLocation()
            locationManager?.startUpdatingHeading()
            trackStartTime = Timestamp(date: Date())
            
        } else {
            
            focusUserLocation()
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                
                self?.saveTrackButton.center.x = 250
                self?.deleteTrackButton.center.x = 150
            }
        }
    }
    
    @objc func didTapSaveTrack() {
        
        lottie.startLoading()
        
        let coordinate = userStoredLocations.map { $0.coordinate }
        let track = coordinate.map { $0.transferToGeopoint() }
        
        guard let userCurrentPet = userCurrentPet,
              !coordinate.isEmpty else {
            
            lottie.stopLoading()
            
            return
        }
        
        let distance = computeDistance(from: track.map { $0.transferToCoordinate2D() })
        
        var trackInfo = TrackInfo(id: "",
                                  petId: userCurrentPet.id,
                                  distanceMeter: distance,
                                  startTime: trackStartTime,
                                  endTime: Timestamp(),
                                  track: track,
                                  note: "")
        
        mapManager.uploadTrack(userId: user.id, trackInfo: &trackInfo) { [weak self] result in
            
            switch result {
                
            case .success(let trackInfo):
                
                self?.mapView.removeOverlays(self?.mapView.overlays ?? [])
                
                self?.lottie.stopLoading()
                
                self?.didFinishTrackButtons()
                
                let trackHistoryVC = TrackHistoryViewController(pet: userCurrentPet,
                                                                trackInfo: trackInfo,
                                                                shouldEdit: true)
                
                NotificationCenter.default.post(name: .updateTrackHistory, object: .none)
                
                self?.navigationController?.pushViewController(trackHistoryVC, animated: true)
                
            case .failure(let error):
                
                self?.lottie.stopLoading()
                self?.lottie.showError(error: error)
            }
        }
    }
    
    func computeDistance(from points: [CLLocationCoordinate2D]) -> Double {
        
        guard let first = points.first else { return 0.0 }
        
        var prevPoint = first
        
        return points.reduce(0.0) { (count, point) -> Double in
            
            let newCount = count + CLLocation(latitude: prevPoint.latitude, longitude: prevPoint.longitude).distance(
                
                from: CLLocation(latitude: point.latitude, longitude: point.longitude))
            
            prevPoint = point
            
            return newCount
        }
    }
    
    @objc func didTapDeleteTrack() {
        
        didFinishTrackButtons()
        mapView.removeOverlays(mapView.overlays)
    }
    
    func didFinishTrackButtons() {
        
        locationManager?.stopUpdatingLocation()
        locationManager?.stopUpdatingHeading()
        
        userStoredLocations = []
        
        mapView.isUserInteractionEnabled = true
        
        userLocationButton.isHidden = false
        
        choosePetImageView.isHidden = false
        
        saveTrackButton.isHidden = true
        deleteTrackButton.isHidden = true
        
        mapManager.changeUserStatus(userId: user.id, status: .unTrack) { [weak self] result in
            switch result {
                
            case .success:
                
                print("===renew status success")
                
            case .failure(let error):
                print(error)
                self?.lottie.showError(error: error)
            }
        }
    }
    
    @objc func didTapChoosePet() {
        
        let choosePetVC = ChoosePetViewController(pets: userPets, isPost: false)
        
        choosePetVC.delegate = self
        
        let navChoosePetVC = UINavigationController(rootViewController: choosePetVC)

        if let sheet = navChoosePetVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.preferredCornerRadius = 20
        }
        
        present(navChoosePetVC, animated: true, completion: nil)
    }
    
    @objc func didTapStrangerButton() {
        
        strangerButton.isSelected = !strangerButton.isSelected
        
        collectionView.isHidden = !strangerButton.isSelected
        
//        if Auth.auth().currentUser != nil,
//            userCurrentPet != nil {
//
//            if locationManager?.authorizationStatus == .denied ||
//                locationManager?.authorizationStatus == .restricted ||
//                locationManager?.authorizationStatus == .notDetermined {
//
//                trackButton.isHidden = true
//            } else {
//                trackButton.isHidden = strangerButton.isSelected
//            }
//
//            if !trackButton.isSelected || !user.petsId.isEmpty {
//                choosePetImageView.isHidden = strangerButton.isSelected
//            }
//        }
//        userLocationButton.isHidden = strangerButton.isSelected
//
        mapManager.fetchStrangerLocations(friend: user.friends, blockIds: user.blockUsersId) { [weak self] result in
            
            switch result {
                
            case .success(let strangerLocations):
                
                guard var nearStrangersId = self?.getNearStrangersId(strangerLocations: strangerLocations) else {
                    print(FirebaseError.fetchStangerError.errorMessage)
                    return
                }
                
                nearStrangersId.removeAll(where: { $0 == self?.user.id })
                
                self?.fetchPets(from: nearStrangersId) { pets in
                    
                    self?.strangersPet = pets
                }
                
            case .failure(let error):
                
                print(error)
            }
        }
    }

    func getNearStrangersId(strangerLocations: [UserLocation]) -> [String] {

        var nearbyStrangeLocations: [UserLocation] = []

        guard let myLocation = mapView.userLocation.location else { return [] }

        for strangerLocation in strangerLocations {

            let latitude = strangerLocation.location.latitude

            let longitude = strangerLocation.location.longitude
            
            let strangerCordLocation = CLLocation(latitude: latitude, longitude: longitude)

            let distance = myLocation.distance(from: strangerCordLocation) / 1000
            
            if distance < 6 {
                
                nearbyStrangeLocations.append(strangerLocation)
            }
        }
        
        return nearbyStrangeLocations.map { $0.userId }
    }
    
    @objc func didTapNotificationButton() {
        
        let friendRequestVC = FriendRequestViewController()
        
        navigationController?.pushViewController(friendRequestVC, animated: true)
    }
    
    func fetchPets(from usersId: [String], completion: @escaping ([Pet]) -> Void) {
        
        let group = DispatchGroup()
        
        var fetchedPets: [Pet] = []
        
        for userId in usersId {
            
            group.enter()
            
            self.userManager.fetchPets(userId: userId) { result in
                
                switch result {
                    
                case.success(let pets):
                    
                    fetchedPets.append(contentsOf: pets)
                    
                    group.leave()
                    
                case .failure(let error):
                    
                    print(error)
                    
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            
            completion(fetchedPets)
        }
    }
    
    func listenFriendsLocation() {
        
        if listeners.count != 0 {
            
            listeners.forEach { $0.remove() }
        }

        let friends = user.friends
        
        for friend in friends {
            
           let listener = mapManager.listenFriendsLocation(friend: friend) { [weak self] result in
                
                switch result {
                    
                case .success(let friendlocation):
                    
                    self?.friendLocations[friendlocation.userId] = friendlocation
                    
                case .failure(let error):
                    
                    print(error)
                }
            }
            listeners.append(listener)
        }
    }
    
    func updateAnnotation() {
        
        mapView.removeAnnotations(mapView.annotations)
        
        for friend in friendLocations.values {
            
            if friend.status == Status.tracking.rawValue {
            
                let annotation = UserAnnotation(coordinate: friend.location.transferToCoordinate2D(),
                                                title: friend.petName,
                                                subtitle: friend.userName,
                                                userId: friend.userId,
                                                petPhoto: friend.petPhoto)
                
                friendAnnotationsInfo[friend.userId] = annotation
            } else {
                
                friendAnnotationsInfo.removeValue(forKey: friend.userId)
            }
        }
        
        for friendAnnotationInfo in friendAnnotationsInfo {
                
            mapView.addAnnotation(friendAnnotationInfo.value)

        }
    }
    
    func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {

           UIApplication.shared.open(settingsUrl)
         }
    }
    
    func setLocationAlert() {
        
        locationAlertController = UIAlertController(title: "Allow \"PawKing\" To Access Your Location While You Use The App." ,
                                                message: "PawKing requires your precise location to track your walk.",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        locationAlertController?.addAction(cancelAction)
        
        let settingAction = UIAlertAction(title: "Settings", style: .default) { _ in
            self.openAppSettings()
        }
        locationAlertController?.addAction(settingAction)
    }
    
    func setNoPetAlert() {
        
        let noPetCancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
            
            self.tabBarController?.selectedIndex = 4
        })
        
        noPetAlertController.addAction(noPetCancelAction)
    }
}

extension MapViewController: ChoosePetViewDelegate {
    
    func didChoosePet(with selectedPet: Pet) {
        
        self.userCurrentPet = selectedPet
        
        userManager.updateCurrentPet(userId: user.id, pet: selectedPet) { result in
            
            switch result {
                
            case .success:
                
                print("=== Change current Pet complete")
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
}

extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let locationStatus = manager.authorizationStatus
        
        switch locationStatus {
            
        case .restricted, .denied:
            
            if let locationAlert = self.locationAlertController {
                self.present(locationAlert, animated: true)
            }
            
            locationManager?.requestWhenInUseAuthorization()

        default:
            
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let currentLocation = locations.first(where: { $0.horizontalAccuracy >= 0 }) else {
                return
            }
        
        let previousCoordinate = userStoredLocations.last?.coordinate
        
        userStoredLocations.append(currentLocation)
        
        if previousCoordinate == nil { return }

        var coordinates = [previousCoordinate!, currentLocation.coordinate]
    
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        
        mapView.addOverlay(polyline, level: .aboveLabels)
        
        guard let location = locations.last?.coordinate,
              let currentPet = userCurrentPet
        else {
            return
        }
        
        let userLocation = UserLocation(userId: user.id,
                                        userName: user.name,
                                        userPhoto: user.userImage,
                                        currentPetId: currentPet.id,
                                        petName: currentPet.name,
                                        petPhoto: currentPet.petImage,
                                        location: location.transferToGeopoint(),
                                        status: Status.tracking.rawValue)
        
        userManager.updateUserLocation(location: userLocation) { result in
            
            switch result {
                
            case .success:
                
                print("===renew success")
                
            case.failure(let error):
                
                print(error)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            
            polylineRenderer.strokeColor = .Orange1
            
            polylineRenderer.lineWidth = 4
                    
            return polylineRenderer
            
        } else {
            
            return MKPolylineRenderer()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        guard let annotation = annotation as? UserAnnotation else { return MKAnnotationView() }
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "UserAnnotationView",
                                                                   for: annotation)
        
        guard let imageUrl = URL(string: annotation.petPhoto) else { return annotationView}
        
        let petView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        
        let petNameLabel = UILabel(frame: CGRect(x: -10, y: 65, width: 80, height: 20))
        
        petView.kf.setImage(with: imageUrl)
        petView.layer.cornerRadius = 30
        petView.layer.borderWidth = 2
        petView.layer.borderColor = UIColor.Orange1?.cgColor
        
        petView.contentMode = .scaleAspectFill
        petView.clipsToBounds = true
        petView.isUserInteractionEnabled = true
        
        petNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        petNameLabel.numberOfLines = 3
        petNameLabel.textColor = .Orange1
        petNameLabel.layer.cornerRadius = 10
        
        petNameLabel.text = annotation.title ?? ""
        petNameLabel.textAlignment = .center
        
        annotationView.frame = CGRect(x: 0, y: 0, width: 60, height: 70)
        annotationView.subviews.forEach { $0.removeFromSuperview() }
        annotationView.addSubview(petNameLabel)
        annotationView.addSubview(petView)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        guard let annotation = view.annotation as? UserAnnotation else { return }
        
        let userPhotoWallVC = UserPhotoWallViewController(otherUserId: annotation.userId)

        navigationController?.pushViewController(userPhotoWallVC, animated: true)

//        userManager.fetchUserInfo(userId: annotation.userId) { [weak self] result in
//
//            switch result {
//
//            case .success(let otherUser):

//                guard let user = self?.user else { return }
//
//            case .failure(let error):
//
//                print(error)

//            }
//        }
    }
}

extension MapViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard Auth.auth().currentUser != nil else {
            
            NotificationCenter.default.post(name: .showSignInView, object: .none)
            return
        }
        
        guard strangersPet.count != 0 else { return }
        
//        userManager.fetchUserInfo(userId: strangersPet[indexPath.item].ownerId) { [weak self] result in
//
//            switch result {
//
//            case .success(let otherUser):

//                guard let user = self?.user else { return }

                let userPhotoWallVC = UserPhotoWallViewController(otherUserId: strangersPet[indexPath.item].ownerId)

                navigationController?.pushViewController(userPhotoWallVC, animated: true)

//            case .failure(let error):
//
//                print(error)

//            }
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        strangersPet.count == 0 ? 1 : strangersPet.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if strangersPet.count == 0 {
        
            guard let noStrangerCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NoStrangerCell.identifier,
                for: indexPath) as? NoStrangerCell else {
                
                fatalError("Can not dequeue NoStrangerCell")
            }
            
            return noStrangerCell
            
        } else {
            
            guard let strangerCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: StrangerCardViewCell.identifier,
                for: indexPath) as? StrangerCardViewCell else {
                
                fatalError("Can not dequeue StrangerCardViewCell")
            }
            
            strangerCell.configuerCell(with: strangersPet[indexPath.item])
            
            return strangerCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let frameSize = collectionView.frame.size
            return frameSize.width * 0.1
        }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let frameSize = collectionView.frame.size
        return CGSize(width: frameSize.width * 0.7, height: frameSize.height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let frameSize = collectionView.frame.size
        return UIEdgeInsets(top: 0, left: frameSize.width * 0.15, bottom: 0, right: frameSize.width * 0.15)
    }
}

// swiftlint:enable file_length
