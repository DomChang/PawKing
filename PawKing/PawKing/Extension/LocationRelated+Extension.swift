//
//  LocationRelated+Extension.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/16.
//

import MapKit
import FirebaseFirestore

extension CLLocationCoordinate2D {
    
    func transferToGeopoint() -> GeoPoint {
        
        let geoPoint = GeoPoint(latitude: self.latitude,
                                longitude: self.longitude)
        
        return geoPoint
    }
    
    func distanceTo(coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        
        let thisLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        
        let otherLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        return thisLocation.distance(from: otherLocation)
    }
}

extension GeoPoint {
    
    func transferToCoordinate2D() -> CLLocationCoordinate2D {
        
        let coordinate2D = CLLocationCoordinate2D(latitude: self.latitude,
                                                  longitude: self.longitude)
        
        return coordinate2D
    }
}

extension CLLocationManager {
    
    func checkLocationPermission() {
        
        if self.authorizationStatus != .authorizedWhenInUse && self.authorizationStatus != .authorizedAlways {
            
            self.requestAlwaysAuthorization()
            
        }
        
    }
    
}
