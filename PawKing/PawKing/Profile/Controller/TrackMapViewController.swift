//
//  TrackMapViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/30.
//

import UIKit
import MapKit

class TrackMapViewController: UIViewController {
    
    let mapView = MKMapView()
    
    private let timeTitleLabel = UILabel()
    
    private let distanceTitleLabel = UILabel()

    let timeLabel = UILabel()

    let distanceLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        style()
        layout()
    }
    
    private func setup() {
        
        mapView.register(TrackAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.delegate = self
        
    }
    
    private func style() {
        
        timeTitleLabel.text = "Time"
        timeTitleLabel.textColor = .BattleGrey
        timeTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        timeLabel.textColor = .CoralOrange
        timeLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        distanceTitleLabel.text = "Distance"
        distanceTitleLabel.textColor = .BattleGrey
        distanceTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        distanceLabel.textColor = .CoralOrange
        distanceLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    private func layout() {
        
        view.addSubview(mapView)
        
        mapView.fillSuperview()
        
        let timeVStack = UIStackView(arrangedSubviews: [timeTitleLabel, timeLabel])
        
        timeVStack.axis = .vertical
        timeVStack.distribution = .fill
        timeVStack.spacing = 3
        
        let distanceVStack = UIStackView(arrangedSubviews: [distanceTitleLabel, distanceLabel])
        
        distanceVStack.axis = .vertical
        distanceVStack.distribution = .fill
        distanceVStack.spacing = 3

        let infoHStack = UIStackView(arrangedSubviews: [timeVStack, distanceVStack])
        
        infoHStack.axis = .horizontal
        infoHStack.distribution = .equalCentering
        infoHStack.spacing = 10
        infoHStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 30, bottom: 0, trailing: 30)
        infoHStack.isLayoutMarginsRelativeArrangement = true
        infoHStack.backgroundColor = .white
        
        infoHStack.layer.cornerRadius = 20
        infoHStack.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        distanceVStack.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        view.addSubview(infoHStack)
        
        infoHStack.anchor(leading: view.leadingAnchor,
                          bottom: view.bottomAnchor,
                          trailing: view.trailingAnchor)
    }
    
    func drawTrack(coordinates: [CLLocationCoordinate2D]) {

        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)

        mapView.addOverlay(polyline, level: .aboveRoads)
        
        var regionRect = polyline.boundingMapRect

       let wPadding = regionRect.size.width * 0.8
       let hPadding = regionRect.size.height * 0.8

       // Add padding to the region
       regionRect.size.width += wPadding
       regionRect.size.height += hPadding

       // Center the region on the line
       regionRect.origin.x -= wPadding / 2
       regionRect.origin.y -= hPadding / 2

        mapView.setRegion(MKCoordinateRegion(regionRect), animated: true)
    }
    
    func setAnnotation(trackInfo: TrackInfo) {
        
        guard let startPoint = trackInfo.track.first,
                let endPoint = trackInfo.track.last else { return }
        
        let startTime = trackInfo.startTime.dateValue().displayTimeInHourMinuteStyle()
        
        let endTime = trackInfo.endTime.dateValue().displayTimeInHourMinuteStyle()
        
        let startAnnotation = TrackAnnotation(title: "Start",
                                              subtitle: startTime,
                                              coordinate: startPoint.transferToCoordinate2D())
        
        let endAnnotation = TrackAnnotation(title: "End",
                                            subtitle: endTime,
                                            coordinate: endPoint.transferToCoordinate2D())
        
        mapView.addAnnotations([startAnnotation, endAnnotation])
    }
}

extension TrackMapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // do not alter user location marker
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }

        // get existing marker
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "reuseIdentifier") as? TrackAnnotationView

        // is this a new marker (i.e. nil)?
        if view == nil {
            view = TrackAnnotationView(annotation: nil, reuseIdentifier: "reuseIdentifier")
        }

        view?.subtitleVisibility = .visible

        return view
    }

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
}
