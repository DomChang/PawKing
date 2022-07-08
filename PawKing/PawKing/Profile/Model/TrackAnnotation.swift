//
//  TrackAnnotation.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/7.
//

import MapKit

class TrackAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D

    init(title: String?,
         coordinate: CLLocationCoordinate2D) {
        
        self.title = title
        self.coordinate = coordinate
        super.init()
    }
}
