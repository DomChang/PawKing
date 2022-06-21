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

class MapViewController: UIViewController {
    
    let mapView = MKMapView()
    
    let locationManager = CLLocationManager()
    
    let userLocationButton = UIButton()
    
    let trackButton = UIButton()
    
    let saveTrackButton = UIButton()
    
    let deleteTrackButton = UIButton()
    
    let strangerButton = UIButton()
    
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
    
    private var user: User?
    
    var friendAnnotationsInfo: [String: UserAnnotation] = [:]
    
    var friendLocations: [String: UserLocation] = [:] {
        didSet {
            updateAnnotation()
        }
    }
    
    let userId = "oSLzURakUCoCClw5IT4R"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        setup()
        style()
        layout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        didSelectUserLocation()
        
        var user = User(id: userId,
                        name: "ray",
                        petsId: ["123", "456", "789"],
                        userImage: "",
                        description: "",
                        friendPetsId: [],
                        friends: ["YKLdeY8JFgJ6OCK3Dg55",
                                  "6LekOapG0PZ0rmTMXXfZ",
                                  "tAC8KcfV261Gv3uUpUEj"],
                        recieveFriendRequest: [],
                        sendRequestsId: [])

        userManager.updateUserInfo(user: user) { result in
            switch result {

            case .success:

                print("success")

            case .failure(let error):
                print(error)
            }
        }
        
//        userManager.setupUser(user: &user) { result in
//            switch result {
//
//            case .success:
//
//                print("success")
//
//            case .failure(let error):
//                print(error)
//            }
//        }
        
//        var pet = Pet(id: "",
//                      ownerId: "YKLdeY8JFgJ6OCK3Dg55",
//                      name: "fuby",
//                      gender: 0,
//                      breed: "",
//                      description: "",
//                      birthday: Timestamp(),
//                      petImage: <#T##String#>,
//                      postsId: <#T##[String]#>,
//                      tracksId: <#T##[String]#>,
//                      personality: <#T##PetPersonality#>)
//
    }
    
    deinit {
        
        mapView.delegate = nil
    }
    
    func setup() {
        
        strangerButtonDisable()
        
        userManager.fetchUserInfo(userId: userId) { [weak self] result in
            
            switch result {
                
            case .success(let user):
                
                self?.user = user
                self?.listenFriendsLocation()
                self?.strangerButtonEnable()
                
            case .failure(let error):
                
                print(error)
            }
        }
        
        locationManager.requestWhenInUseAuthorization()
        
        mapView.showsUserLocation = true
        mapView.mapType = .mutedStandard
        
        locationManager.delegate = self
        mapView.delegate = self
        
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
        
        strangerButton.setTitle("陌生", for: .normal)
//        strangerButton.backgroundColor = .G1
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
    }
    
    @objc func didSelectUserLocation() {
        
        userLocationButton.isSelected = true
        
        mapView.userTrackingMode = .follow
        
        focusUserLocation()
    }
    
    func focusUserLocation() {
    
        let location = mapView.userLocation
        
        mapView.setRegion(MKCoordinateRegion(center: location.coordinate,
                                             latitudinalMeters: 1000,
                                             longitudinalMeters: 1000),
                                             animated: true)
    }
    
    @objc func didTapRecordTrack() {
        
        trackButton.isSelected = !trackButton.isSelected
        saveTrackButton.isHidden = trackButton.isSelected
        deleteTrackButton.isHidden = trackButton.isSelected
        
        userLocationButton.isHidden = !trackButton.isSelected
        
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
        
        var trackInfo = TrackInfo(id: userId,
                          petId: ["petId"],
                          screenShot: "",
                          startTime: trackStartTime,
                          endTime: Timestamp(),
                          track: track,
                          note: "")
        
        mapManager.uploadTrack(trackInfo: &trackInfo) { [weak self] result in
            
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
        
        saveTrackButton.isHidden = true
        deleteTrackButton.isHidden = true
        
        mapManager.changeUserStatus(userId: userId, status: .unTrack) { result in
            switch result {
                
            case .success:
                
                print("===renew statu success")
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    @objc func didTapStrangerButton() {
        
        guard let user = user else {
            return
        }

        let friends = user.friends
        
        strangerButton.isSelected = !strangerButton.isSelected
        
        collectionView.isHidden = !strangerButton.isSelected
        
        mapManager.fetchStrangerLocations(friend: friends) { [weak self] result in
            
            switch result {
                
            case .success(let strangerLocations):
                
                guard let nearStrangersId = self?.getNearStrangersId(strangerLocations: strangerLocations) else {
                    print(FirebaseError.fetchStangerError.errorMessage)
                    return
                }
                
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
            
            self.userManager.fetchPetsbyUser(user: userId) { result in
                
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
        
        guard let user = user else {
            return
        }

        let friends = user.friends
        
        for friend in friends {
            
            mapManager.listenFriendsLocation(friend: friend) { [weak self] result in
                
                switch result {
                    
                case .success(let friendlocation):
                    
                    self?.friendLocations[friendlocation.userId] = friendlocation
                    
//                    guard let friendLocations = self?.friendLocations else { return }
//
//                    for friendLocation in friendLocations {
//
//                        if friendLocation.userId == updatedFriendlocation.userId {
//
//                            guard let index = friendLocations.firstIndex(of: friendLocation) else { return }
//
//                            self?.friendLocations[index] = updatedFriendlocation
//
//                        } else {
//
//                            self?.friendLocations.append(updatedFriendlocation)
//                        }
//                    }
                    
                case .failure(let error):
                    
                    print(error)
                }
            }
        }
    }
    
    func updateAnnotation() {
        
        for annotation in mapView.annotations{
            
            mapView.removeAnnotation(annotation)
        }
        
        for friend in friendLocations.values {
            
            guard friend.status == Status.tracking.rawValue else { return }
                
            let annotation = UserAnnotation(coordinate: friend.location.transferToCoordinate2D(),
                                            title: "",
                                            subtitle: friend.userName,
                                            userId: friend.userId,
                                            petPhoto: "")
            
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
        
        guard let location = locations.last?.coordinate else { return }
        
        let userLocation = UserLocation(userId: userId,
                                        userName: "Dom",
                                        userPhoto: "",
                                        currentPetId: ["currentPetId"],
                                        petName: [],
                                        petPhoto: [],
                                        location: location.transferToGeopoint(),
                                        status: Status.tracking.rawValue)
        
        mapManager.updateUserLocation(location: userLocation) { result in
            
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
//        guard let userAnnotation = annotation as? UserAnnotation else { return MKMarkerAnnotationView() }
        
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "UserAnnotation")
        
        // MARK: Wait change to annotation.petPhoto
        let image = UIImage(named: "Icons_24px_Chat_Normal")
        
        annotationView.glyphImage = image
        
        annotationView.markerTintColor = .G1
        
        return annotationView
    }
}

extension MapViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        strangersPet.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StrangerCardViewCell.identifier,
            for: indexPath) as? StrangerCardViewCell else {
            
            fatalError("Can not dequeue StrangerCardViewCell")
        }
        
        cell.configuerCell(with: strangersPet[indexPath.item])
        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let frameSize = collectionView.frame.size
            return frameSize.width * 0.1
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

            let frameSize = collectionView.frame.size
            return CGSize(width: frameSize.width * 0.6, height: frameSize.height)
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            let frameSize = collectionView.frame.size
            return UIEdgeInsets(top: 0, left: frameSize.width * 0.2, bottom: 0, right: frameSize.width * 0.2)
        }
}
