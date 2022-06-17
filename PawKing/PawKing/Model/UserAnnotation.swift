//
//  PKAnnotation.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/16.
//

import Foundation
import MapKit

class UserAnnotation: NSObject, MKAnnotation {

    let coordinate: CLLocationCoordinate2D
    
    let title: String?
    
    let subtitle: String?
    
    var userId: String
    
    var petPhoto: String?
  

    init(
        coordinate: CLLocationCoordinate2D,
        title: String,
        subtitle: String,
        userId: String,
        petPhoto: String
    ) {
        self.coordinate = coordinate
        
        self.title = title
        
        self.subtitle = subtitle
        
        self.userId = userId
        
        self.petPhoto = petPhoto
    }
}
