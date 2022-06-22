//
//  TrackHistoryViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/21.
//

import UIKit
import MapKit

class TrackHistoryViewController: UIViewController {
    
    private let petName: String
    
    private let petImageURL: URL
    
    private let trackInfo: TrackInfo
    
    private let petNameLabel = UILabel()
    
    private let petImageView = UIImageView()
    
    private let mapView = MKMapView()
    
    private let noteLabel = UILabel()
    
    init(petName: String, petImageURL: URL, trackInfo: TrackInfo) {
        
        self.petName = petName
        
        self.petImageURL = petImageURL
        
        self.trackInfo = trackInfo
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        style()
        layout()
    }
    
    func setup() {
        
        petImageView.kf.setImage(with: petImageURL)
        
        petNameLabel.text = petName
        
        noteLabel.text = trackInfo.note
        
        let location = trackInfo.track[0].transferToCoordinate2D()
        
        let region = MKCoordinateRegion(center: location,
                                        span: .init(latitudeDelta: 0.005,
                                                    longitudeDelta: 0.005))
        
        mapView.setRegion(region, animated: false)
        
        mapView.delegate = self
        
        drawTrack()
    }
    
    func style() {
        
        view.backgroundColor = .white
        
        petNameLabel.textColor = .brown
        petNameLabel.font = UIFont.systemFont(ofSize: 20)
        
        noteLabel.textColor = .brown
        noteLabel.font = UIFont.systemFont(ofSize: 16)
    }
    
    func layout() {
        
        view.addSubview(petImageView)
        view.addSubview(petNameLabel)
        view.addSubview(mapView)
        view.addSubview(noteLabel)
        
        petImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                            leading: view.leadingAnchor,
                            width: 40,
                            height: 40,
                            padding: UIEdgeInsets(top: 30, left: 20, bottom: 0, right: 0))
        
        petNameLabel.anchor(leading: petImageView.trailingAnchor,
                            trailing: view.trailingAnchor,
                            centerY: petImageView.centerYAnchor,
                            padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20))
        
        mapView.anchor(top: petNameLabel.bottomAnchor,
                       leading: view.leadingAnchor,
                       trailing: view.trailingAnchor,
                       height: view.frame.height / 2,
                            padding: UIEdgeInsets(top: 20, left: 30, bottom: 0, right: 30))
        
        noteLabel.anchor(top: mapView.bottomAnchor,
                         leading: mapView.leadingAnchor,
                         trailing: mapView.trailingAnchor,
                            padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        
        view.layoutIfNeeded()
        petImageView.makeRound()
        petImageView.clipsToBounds = true
        
        mapView.layer.cornerRadius = mapView.frame.height / 10
    }
    
    func drawTrack() {
        
        let coordinates = trackInfo.track.map { $0.transferToCoordinate2D() }

        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)

        mapView.addOverlay(polyline, level: .aboveRoads)
    }
}

extension TrackHistoryViewController: MKMapViewDelegate, CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        
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
}
