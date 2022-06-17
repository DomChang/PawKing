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
    
    var userStoredLocations: [CLLocation] = []
    
    let mapManager = MapManager()
    
    var trackStartTime = Timestamp()
    
    private var user: User?
    
    var friendAnnotationsInfo: [String: UserAnnotation] = [:]
    
    var friendLocations: [String: UserLocation] = [:] {
        didSet {
            updateAnnotation()
        }
    }
    
    let userId = "LI2XA6ImsVOvWE0eHU4U"

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
        
//        let user = User(id: "Xv0pEmNaLobBb7KUcOfO",
//                        name: "Dom",
//                        petsId: ["123", "456", "789"],
//                        userImage: "",
//                        description: "",
//                        friendPetsId: [],
//                        friends: ["8ZfXYhs9A4YjcI0oVFhi",
//                                  "JZJrToyHcfeOy4uNphcP",
//                                  "LI2XA6ImsVOvWE0eHU4U"],
//                        recieveFriendRequest: [],
//                        sendRequestsId: [])
//
//        mapManager.updateUserInfo(user: user) { result in
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
    }
    
    deinit {
        
        mapView.delegate = nil
    }
    
    func setup() {
        
        mapManager.fetchUserInfo(userId: "Xv0pEmNaLobBb7KUcOfO") { [weak self] result in
            
            switch result {
                
            case .success(let user):
                
                self?.user = user
                self?.listenFriendsLocation()
                
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
        
        saveTrackButton.isHidden = true
        deleteTrackButton.isHidden = true
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
        
    }
    
    func layout() {
        
        view.addSubview(mapView)
        view.addSubview(userLocationButton)
        view.addSubview(trackButton)
        view.addSubview(saveTrackButton)
        view.addSubview(deleteTrackButton)
        
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
        
        var trackInfo = TrackInfo(id: "",
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
        
        //MARK: Wait change to annotation.petPhoto
        let image = UIImage(named: "Icons_24px_Chat_Normal")
        
        annotationView.glyphImage = image
        
        annotationView.markerTintColor = .G1
        
        return annotationView
    }
}
