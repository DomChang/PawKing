//
//  MapViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/20.
//

import UIKit
import MapKit
import FirebaseFirestore

protocol MapViewDelegate: AnyObject {
    
    func showLocationAlert()
    
    func setCurrentPetButton()
}

class MapViewController: UIViewController {
    
    var delegate: MapViewDelegate?
    
    var locationManager: CLLocationManager?
    
    let mapView = MKMapView()
    
    let trackDashboardView = TrackDashboardView()
    
    var infoBottomAnchor: NSLayoutConstraint!
    
    var distance: Double = 0
    
    var userStoredLocations: [CLLocation] = []
    
    private let userLocationButton = UIButton()
    
    private var friendAnnotationsInfo: [String: UserAnnotation] = [:]

    private var friendLocations: [String: UserLocation] = [:] {
        didSet {
            updateAnnotation()
        }
    }
    
    var userCurrentPet: Pet? {
        didSet {
            self.delegate?.setCurrentPetButton()
        }
    }
    
    private var listeners: [ListenerRegistration] = []
    
    private let locationHelper = LocationHelper()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        style()
        layout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard locationManager?.authorizationStatus != .denied &&
                locationManager?.authorizationStatus != .restricted &&
                locationManager?.authorizationStatus != .notDetermined else {
            
            return
        }
        mapView.userTrackingMode = .follow
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mapView.removeAnnotations(mapView.annotations)
        
        listeners.forEach { $0.remove() }
    }
    
    private func setup() {
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.distanceFilter = 20
        locationManager?.checkLocationPermission()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.mapType = .mutedStandard
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "UserAnnotationView")
        
        userLocationButton.addTarget(self, action: #selector(didSelectUserLocation), for: .touchUpInside)
    }
    
    private func style() {
        
        mapView.layer.cornerRadius = 20
        mapView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        userLocationButton.setImage(UIImage.asset(.Icons_60px_UserLocate), for: .normal)
    }
    
    private func layout() {
        
        view.addSubview(mapView)
        view.addSubview(trackDashboardView)
        view.addSubview(userLocationButton)
        
        mapView.fillSuperview()
        
        userLocationButton.anchor(bottom: view.bottomAnchor,
                                  trailing: view.trailingAnchor,
                                  width: 36,
                                  height: 36,
                                  padding: UIEdgeInsets(top: 0, left: 0, bottom: 35, right: 35))
        
        trackDashboardView.anchor(leading: view.leadingAnchor,
                            trailing: view.trailingAnchor,
                            height: view.safeAreaInsets.top + 90,
                            padding: UIEdgeInsets(top: 0, left: 116, bottom: 0, right: 116))
        
        infoBottomAnchor = trackDashboardView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        infoBottomAnchor.isActive = true
        
        userLocationButton.setRadiusWithShadow()
    }
    
    @objc private func didSelectUserLocation() {
        
        guard isLocationAuth() else {
            
            self.delegate?.showLocationAlert()
            return
        }
        
        userLocationButton.isSelected = true
        
        focusUserLocation()
        
        mapView.userTrackingMode = .follow
    }
    
    func isLocationAuth() -> Bool {
        
        if locationManager?.authorizationStatus != .denied &&
            locationManager?.authorizationStatus != .restricted &&
            locationManager?.authorizationStatus != .notDetermined {
            
            return true
        } else {
            
            return false
        }
    }
    
    func startUpdateLocation() {
        
        locationManager?.startUpdatingLocation()
        locationManager?.startUpdatingHeading()
    }
    
    func stopUpdateLocation(user: User) {
        
        locationManager?.stopUpdatingLocation()
        locationManager?.stopUpdatingHeading()
        
        userStoredLocations = []
        
        MapManager.shared.changeUserStatus(userId: user.id, status: .unTrack)
    }
    
    func focusUserLocation() {
    
        let location = mapView.userLocation
        
        let region = MKCoordinateRegion(center: location.coordinate,
                                        span: .init(latitudeDelta: 0.01,
                                                    longitudeDelta: 0.01))
        mapView.setRegion(region, animated: false)
    }
    
    func getCurrentPet(user: User, userPets: [Pet]) {
        
        UserManager.shared.fetchUserLocation(userId: user.id) { [weak self] result in
            switch result {
                
            case .success(let userLocation):
                
                guard let self = self else { return }
                
                if userPets.contains(where: {$0.id == userLocation.currentPetId}) {
                    
                    userPets.forEach({ pet in
                        
                        if pet.id == userLocation.currentPetId {
                            
                            self.userCurrentPet = pet
                        }
                    })
                } else {
                    
                    self.userCurrentPet = nil
                }
            case .failure:
                
                self?.userCurrentPet = nil
            }
        }
    }
    
    func listenFriendsLocation(user: User) {
        
        if listeners.count != 0 {
            
            listeners.forEach { $0.remove() }
        }

        let friends = user.friends
        
        for friend in friends {
            
           let listener = MapManager.shared.listenFriendsLocation(friend: friend) { [weak self] result in
                
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
    
    private func updateAnnotation() {
        
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
    
    func removeFriendLocation() {
        
        listeners.forEach { $0.remove() }
        
        friendAnnotationsInfo = [:]
        
        friendLocations = [:]
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let locationStatus = manager.authorizationStatus

        switch locationStatus {

        case .restricted, .denied:

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
              let currentPet = userCurrentPet,
              let user = UserManager.shared.currentUser
        else {
            return
        }
        
        distance += locationHelper.computeDistance(from: coordinates) / 1000
        
        trackDashboardView.distanceLabel.text = "\(String(format: "%.2f", distance)) km"
        
        let userLocation = UserLocation(userId: user.id,
                                        userName: user.name,
                                        userPhoto: user.userImage,
                                        currentPetId: currentPet.id,
                                        petName: currentPet.name,
                                        petPhoto: currentPet.petImage,
                                        location: location.transferToGeopoint(),
                                        status: Status.tracking.rawValue)
        
        UserManager.shared.updateUserLocation(location: userLocation) { result in
            
            switch result {
                
            case .success:
                
                print("===renew success")
                
            case.failure(let error):
                
                print(error)
            }
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            
            polylineRenderer.strokeColor = .CoralOrange
            
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
        petView.layer.borderColor = UIColor.CoralOrange?.cgColor
        
        petView.contentMode = .scaleAspectFill
        petView.clipsToBounds = true
        petView.isUserInteractionEnabled = true
        
        petNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        petNameLabel.numberOfLines = 3
        petNameLabel.textColor = .CoralOrange
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
    }
}
