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
    
    let userLocationButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        setup()
        style()
        layout()
    }
    
    func setup() {
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        userLocationButton.isSelected = true
        focusUserLocation()
        
        userLocationButton.addTarget(self, action: #selector(didSelectUserLocation), for: .touchUpInside)
    }
    
    func style() {
        
        userLocationButton.setImage(UIImage.asset(.Icons_36px_UserLocate_Normal), for: .normal)
        userLocationButton.setImage(UIImage.asset(.Icons_36px_UserLocate_Selected), for: .selected)
    }
    
    func layout() {
        
        view.addSubview(mapView)
        view.addSubview(userLocationButton)
        
        mapView.fillSuperview()
        
        userLocationButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                  trailing: view.trailingAnchor,
                                  width: 36,
                                  height: 36,
                                  padding: UIEdgeInsets(top: 0, left: 0, bottom: 35, right: 35))
    }
    
    @objc func didSelectUserLocation() {
        
        userLocationButton.isSelected = !userLocationButton.isSelected
        
        if userLocationButton.isSelected {
            
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
            
        } else {
            mapView.setUserTrackingMode(.none, animated: true)
        }
        
        focusUserLocation()
    }
    
    func focusUserLocation() {
    
        let location = mapView.userLocation
        
        mapView.setRegion(MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: true)
        
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        focusUserLocation()
    }
}
