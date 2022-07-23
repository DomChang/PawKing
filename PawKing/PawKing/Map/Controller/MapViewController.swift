//
//  MapViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/20.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    let mapView = MKMapView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        style()
        layout()
    }
    
    private func setup() {
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.mapType = .mutedStandard
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "UserAnnotationView")
    }
    
    private func style() {
        
        mapView.layer.cornerRadius = 20
        mapView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    private func layout() {
        
        view.addSubview(mapView)
        
        mapView.fillSuperview()
    }
    
    func focusUserLocation() {
    
        let location = mapView.userLocation
        
        let region = MKCoordinateRegion(center: location.coordinate,
                                        span: .init(latitudeDelta: 0.01,
                                                    longitudeDelta: 0.01))
        mapView.setRegion(region, animated: false)
    }
}

extension MapViewController: MKMapViewDelegate {
    
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
    }
}
