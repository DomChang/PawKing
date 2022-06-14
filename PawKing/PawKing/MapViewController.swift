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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        setup()
        style()
        layout()
    }
    
    func setup() {
        
    }
    
    func style() {
        
    }
    
    func layout() {
        
        view.addSubview(mapView)
        
        mapView.fillSuperview()
    }
}
