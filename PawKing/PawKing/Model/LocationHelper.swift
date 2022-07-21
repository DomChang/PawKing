//
//  LocationHelper.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/19.
//

import CoreLocation

class LocationHelper {
    
    func computeDistance(from points: [CLLocationCoordinate2D]) -> Double {
        
        guard let first = points.first else { return 0.0 }
        
        var prevPoint = first
        
        let distance = points.reduce(0.0) { (count, point) -> Double in
            
            let newCount = count +
            CLLocation(latitude: prevPoint.latitude, longitude: prevPoint.longitude).distance(
                from: CLLocation(latitude: point.latitude, longitude: point.longitude))
            
            prevPoint = point
            
            return newCount
        }
        return distance
    }
    
    func getNearUsersId(myLocation: CLLocation,
                            userLocations: [UserLocation],
                            distanceKM: Double) -> [String] {

        var nearbyUserLocations: [UserLocation] = []

        for userLocation in userLocations {

            let latitude = userLocation.location.latitude

            let longitude = userLocation.location.longitude
            
            let userCordLocation = CLLocation(latitude: latitude, longitude: longitude)

            let distance = myLocation.distance(from: userCordLocation) / 1000
            
            if distance <= distanceKM {
                
                nearbyUserLocations.append(userLocation)
            }
        }
        return nearbyUserLocations.map { $0.userId }
    }
}
