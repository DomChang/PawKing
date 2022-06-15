//
//  MapViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/14.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    let mapView = MKMapView()
    
    let locationManager = CLLocationManager()
    
    let userLocationButton = UIButton()
    
    let trackButton = UIButton()
    
    var userStoredLocations: [CLLocation] = []

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
    }
    
    func setup() {
        
        locationManager.requestWhenInUseAuthorization()
        
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        mapView.delegate = self
        
        userLocationButton.addTarget(self, action: #selector(didSelectUserLocation), for: .touchUpInside)
        
        trackButton.addTarget(self, action: #selector(didTapRecordTrack), for: .touchUpInside)
    }
    
    func style() {
        
        userLocationButton.setImage(UIImage.asset(.Icons_36px_UserLocate_Normal), for: .normal)
        userLocationButton.setImage(UIImage.asset(.Icons_36px_UserLocate_Selected), for: .selected)
        
        trackButton.setImage(UIImage.asset(.Icons_36px_RecordTrack_Normal), for: .normal)
        trackButton.setImage(UIImage.asset(.Icons_36px_RecordTrack_Selected), for: .selected)
    }
    
    func layout() {
        
        view.addSubview(mapView)
        view.addSubview(userLocationButton)
        view.addSubview(trackButton)
        
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
    }
    
    @objc func didSelectUserLocation() {
        
        userLocationButton.isSelected = true
        
        mapView.userTrackingMode = .followWithHeading
        
        focusUserLocation()
    }
    
    @objc func didTapRecordTrack() {
        
        trackButton.isSelected = !trackButton.isSelected
        
        if trackButton.isSelected {
            
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            
        } else {
            
            locationManager.stopUpdatingLocation()
            locationManager.stopUpdatingHeading()
        }
    }
    
    func focusUserLocation() {
    
        let location = mapView.userLocation
        
        mapView.setRegion(MKCoordinateRegion(center: location.coordinate,
                                             latitudinalMeters: 1000,
                                             longitudinalMeters: 1000),
                                             animated: true)
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
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            
            polylineRenderer.strokeColor = UIColor.red
            
            polylineRenderer.lineWidth = 4
                    
            return polylineRenderer
            
        } else {
            
            return MKPolylineRenderer()
        }
    }
}
