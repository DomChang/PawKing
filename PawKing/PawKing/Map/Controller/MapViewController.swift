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
import Kingfisher

// swiftlint:disable file_length

class MapViewController: UIViewController {
    
    let mapView = MKMapView()
    
    let locationManager = CLLocationManager()
    
    let userLocationButton = UIButton()
    
    let trackButton = UIButton()
    
    let saveTrackButton = UIButton()
    
    let deleteTrackButton = UIButton()
    
    let strangerButton = UIButton()
    
    let choosePetButton = UIButton()
    
    let userSetupButton: UIButton = {
        
        let button = UIButton()
        button.backgroundColor = .O1
        button.setTitle("設定", for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var strangersPet: [Pet] = [] {

        didSet {
            
            collectionView.reloadData()
        }
    }
    
    var userStoredLocations: [CLLocation] = []
    
    let mapManager = MapManager.shared
    
    let userManager = UserManager.shared
    
    var trackStartTime = Timestamp()
    
    private let user: User
    
    var userPets: [Pet] = [] {
        didSet {
            if userPets.count == 0 {
                
                choosePetButton.isHidden = true
            }
        }
    }
    
    var userCurrentPet: Pet? {
        didSet {
            
            trackButton.isHidden = false
            choosePetButton.isHidden = false
            styleCurrentPetButton()
        }
    }
    
    var friendAnnotationsInfo: [String: UserAnnotation] = [:]
    
    var friendLocations: [String: UserLocation] = [:] {
        didSet {
            updateAnnotation()
        }
    }
    
    init(user: User) {
        
        self.user = user
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
        
        setupUserSettingButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        didSelectUserLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    deinit {
        
        mapView.delegate = nil
    }
    
    func setup() {
        
        trackButton.isHidden = true
        
        choosePetButton.isHidden = true
        
        strangerButtonDisable()
        
        listenFriendsLocation()
        
        strangerButtonEnable()
        
        fetchUserPets()
        
        locationManager.requestWhenInUseAuthorization()
        
        mapView.showsUserLocation = true
        mapView.mapType = .mutedStandard
        
        locationManager.delegate = self
        mapView.delegate = self
        
        choosePetButton.addTarget(self, action: #selector(didTapChoosePet), for: .touchUpInside)
        
        userLocationButton.addTarget(self, action: #selector(didSelectUserLocation), for: .touchUpInside)
        
        trackButton.addTarget(self, action: #selector(didTapRecordTrack), for: .touchUpInside)
        
        saveTrackButton.addTarget(self, action: #selector(didTapSaveTrack), for: .touchUpInside)
        
        deleteTrackButton.addTarget(self, action: #selector(didTapDeleteTrack), for: .touchUpInside)
        
        strangerButton.addTarget(self, action: #selector(didTapStrangerButton), for: .touchUpInside)
        
        saveTrackButton.isHidden = true
        
        deleteTrackButton.isHidden = true
        
        collectionView.register(
            StrangerCardViewCell.self,
            forCellWithReuseIdentifier: StrangerCardViewCell.identifier
        )
        
        collectionView.dataSource = self
        
        collectionView.delegate = self
        
        collectionView.isHidden = true
    }
    
    func style() {
        
        userLocationButton.setImage(UIImage.asset(.Icons_36px_UserLocate_Normal), for: .normal)
        userLocationButton.setImage(UIImage.asset(.Icons_36px_UserLocate_Selected), for: .selected)
        
        trackButton.setImage(UIImage.asset(.Icons_36px_RecordTrack_Normal), for: .normal)
        trackButton.setImage(UIImage.asset(.Icons_36px_RecordTrack_Selected), for: .selected)
        
        saveTrackButton.setTitle("儲存", for: .normal)
        saveTrackButton.backgroundColor = .O1
        saveTrackButton.layer.cornerRadius = 5
        
        deleteTrackButton.setTitle("放棄", for: .normal)
        deleteTrackButton.backgroundColor = .G1
        deleteTrackButton.layer.cornerRadius = 5
        
        styleCurrentPetButton()
        
        strangerButton.setTitle("陌生", for: .normal)
        strangerButton.layer.cornerRadius = 5
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
        
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
    }
    
    func layout() {
        
        view.addSubview(mapView)
        view.addSubview(userLocationButton)
        view.addSubview(trackButton)
        view.addSubview(saveTrackButton)
        view.addSubview(deleteTrackButton)
        view.addSubview(strangerButton)
        view.addSubview(collectionView)
        view.addSubview(choosePetButton)
        
        mapView.fillSuperview()
        
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
                              trailing: view.trailingAnchor,
                              width: 60,
                              height: 36,
                              padding: UIEdgeInsets(top: 35, left: 0, bottom: 0, right: 35))
        
        collectionView.anchor(leading: view.leadingAnchor,
                              bottom: view.safeAreaLayoutGuide.bottomAnchor,
                              trailing: view.trailingAnchor,
                              height: 130)
        
        choosePetButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                               centerX: view.centerXAnchor,
                               width: 50,
                               height: 50,
                               padding: UIEdgeInsets(top: 0, left: 0, bottom: 35, right: 0))
    }
    
    func focusUserLocation() {
    
        let location = mapView.userLocation
        
        let region = MKCoordinateRegion(center: location.coordinate,
                                        span: .init(latitudeDelta: 0.01,
                                                    longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: false)
    }
    
    func fetchStoredUserLocation() {
        
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
    
    func fetchUserPets() {
        
        userManager.fetchPets(userId: user.id) { [weak self] result in
            
            switch result {
                
            case .success(let pets):
                
                self?.userPets = pets
                self?.fetchStoredUserLocation()
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func styleCurrentPetButton() {
        
        choosePetButton.layer.masksToBounds = true
        choosePetButton.layoutIfNeeded()
        choosePetButton.makeRound()
        
        if let _ = userCurrentPet {
            
            let imageUrlSting = userCurrentPet!.petImage
            
            choosePetButton.kf.setImage(with: URL(string: imageUrlSting), for: .normal)
        } else {
            
            choosePetButton.setImage(UIImage.asset(.Image_Placeholder), for: .normal)
        }
    }
    
    @objc func didSelectUserLocation() {
        
        userLocationButton.isSelected = true
        
        focusUserLocation()
        
        mapView.userTrackingMode = .follow
    }
    
    @objc func didTapRecordTrack() {
        
        trackButton.isSelected = !trackButton.isSelected
        saveTrackButton.isHidden = trackButton.isSelected
        deleteTrackButton.isHidden = trackButton.isSelected
        
        userLocationButton.isHidden = !trackButton.isSelected
        
        choosePetButton.isHidden = true
        
        mapView.isUserInteractionEnabled = trackButton.isSelected
        
        if trackButton.isSelected {
            
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
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
        
        let coordinate = userStoredLocations.map { $0.coordinate }
        let track = coordinate.map { $0.transferToGeopoint() }
        
        guard let petId = userCurrentPet?.id else {
            return
        }
        
        var trackInfo = TrackInfo(id: user.id,
                          petId: petId,
                          screenShot: "",
                          startTime: trackStartTime,
                          endTime: Timestamp(),
                          track: track,
                          note: "")
        
        mapManager.uploadTrack(userId: user.id, trackInfo: &trackInfo) { [weak self] result in
            
            switch result {
                
            case .success:
                
                print("===success")
                
                self?.didFinishTrackButtons()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc func didTapDeleteTrack() {
        
        didFinishTrackButtons()
    }
    
    func didFinishTrackButtons() {
        
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        
        userStoredLocations = []
        
        mapView.isUserInteractionEnabled = true
        
        userLocationButton.isHidden = false
        
        choosePetButton.isHidden = false
        
        saveTrackButton.isHidden = true
        deleteTrackButton.isHidden = true
        
        mapManager.changeUserStatus(userId: user.id, status: .unTrack) { result in
            switch result {
                
            case .success:
                
                print("===renew status success")
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    @objc func didTapChoosePet() {
        
        let choosePetVC = ChoosePetViewController(pets: userPets)
        
        choosePetVC.delegate = self
        
        let navChoosePetVC = UINavigationController(rootViewController: choosePetVC)
        
        if #available(iOS 15.0, *) {
            if let sheet = navChoosePetVC.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.preferredCornerRadius = 20
            }
        }
        present(navChoosePetVC, animated: true, completion: nil)
    }
    
    @objc func didTapStrangerButton() {
        
//        guard let user = user else {
//            return
//        }

        let friends = user.friends
        
        strangerButton.isSelected = !strangerButton.isSelected
        
        collectionView.isHidden = !strangerButton.isSelected
        
        trackButton.isHidden = strangerButton.isSelected
        choosePetButton.isHidden = strangerButton.isSelected
        userLocationButton.isHidden = strangerButton.isSelected
        
        mapManager.fetchStrangerLocations(friend: friends) { [weak self] result in
            
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
        
//        guard let user = user else {
//            return
//        }

        let friends = user.friends
        
        for friend in friends {
            
            mapManager.listenFriendsLocation(friend: friend) { [weak self] result in
                
                switch result {
                    
                case .success(let friendlocation):
                    
                    self?.friendLocations[friendlocation.userId] = friendlocation
                    
                case .failure(let error):
                    
                    print(error)
                }
            }
        }
    }
    
    func updateAnnotation() {
        
        for annotation in mapView.annotations {
            
            mapView.removeAnnotation(annotation)
        }
        
        for friend in friendLocations.values {
            
            guard friend.status == Status.tracking.rawValue else { return }
                
            let annotation = UserAnnotation(coordinate: friend.location.transferToCoordinate2D(),
                                            title: friend.petName,
                                            subtitle: friend.userName,
                                            userId: friend.userId,
                                            petPhoto: friend.petPhoto)
            
            friendAnnotationsInfo[friend.userId] = annotation
        }
        
        for friendAnnotationInfo in friendAnnotationsInfo {
                
            mapView.addAnnotation(friendAnnotationInfo.value)

        }
    }
    
    func strangerButtonEnable() {
        
        strangerButton.isEnabled = true
        strangerButton.backgroundColor = .O1
    }
    
    func strangerButtonDisable() {
        
        strangerButton.isEnabled = false
        strangerButton.backgroundColor = .G1
    }
    
    func setupUserSettingButton() {
        
        userSetupButton.addTarget(self, action: #selector(showConfigure), for: .touchUpInside)
        
        view.addSubview(userSetupButton)
        
        userSetupButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                               leading: view.leadingAnchor,
                               width: 60,
                               height: 35,
                               padding: UIEdgeInsets(top: 35, left: 35, bottom: 0, right: 0))
    }
    
    @objc func showConfigure() {
        
        let userConfigVC = UserConfigViewController()
        
        navigationController?.pushViewController(userConfigVC, animated: true)
    }
}

extension MapViewController: ChoosePetViewDelegate {
    
    func didChoosePet(with selectedPet: Pet) {
        
        self.userCurrentPet = selectedPet
        
//        guard let user = user else { return }
        
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
//              let user = user
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
            
            polylineRenderer.strokeColor = .O1
            
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
        
        // wait unComment
        guard let userAnnotation = annotation as? UserAnnotation else { return MKMarkerAnnotationView() }
        
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "UserAnnotation")
        
        // MARK: Wait change to annotation.petPhoto
//        let image = UIImage(named: "Icons_24px_Chat_Normal")
        
        guard let imageUrl = URL(string: userAnnotation.petPhoto) else { return annotationView}
        
//        KingfisherManager.shared.retrieveImage(with: imageUrl) { result in
//
//            let image = try? result.get().image
//
//            if let image = image {
//
//                annotationView.glyphImage = image
//            }
//        }
        
        KingfisherManager.shared.retrieveImage(with: imageUrl, completionHandler: { result in
            
            switch result {
                
            case .success(let value):
                
                let resizeImage = value.image.resized(to: CGSize(width: 10, height: 10))
                annotationView.contentMode = .scaleAspectFit
                annotationView.glyphImage = resizeImage
                
            case .failure(let error):
                
                print("Error: \(error)")
            }
        })
        
        annotationView.markerTintColor = .G1
        
        return annotationView
    }
}

extension MapViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        strangersPet.count == 0 ? 1 : strangersPet.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StrangerCardViewCell.identifier,
            for: indexPath) as? StrangerCardViewCell else {
            
            fatalError("Can not dequeue StrangerCardViewCell")
        }
        
        if strangersPet.count == 0 {
            cell.infoLabel.text = "附近沒有陌生寵物"
        } else {
            cell.configuerCell(with: strangersPet[indexPath.item])
        }
        
        return cell
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        return CGSize(width: view.frame.width * 0.5, height: 130)
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout
//    collectionViewLayout: UICollectionViewLayout,
//    minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//
//        return 0
//    }
    
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
            return CGSize(width: frameSize.width * 0.6, height: frameSize.height)
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            insetForSectionAt section: Int) -> UIEdgeInsets {
            let frameSize = collectionView.frame.size
            return UIEdgeInsets(top: 0, left: frameSize.width * 0.2, bottom: 0, right: frameSize.width * 0.2)
        }
}

// swiftlint:enable file_length
