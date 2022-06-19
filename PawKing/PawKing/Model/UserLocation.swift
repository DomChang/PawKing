//
//  UserLocation.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/16.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

enum Status: Int {
    
    case unTrack
    case tracking
}

struct TrackInfo: Codable {
    
    var id: String
    let petId: String
    let screenShot: String
    let startTime: Timestamp
    var endTime: Timestamp
    let track: [GeoPoint]
    let note: String
}

struct UserLocation: Codable {
    
    let userId: String
    let userName: String
    let userPhoto: String
    let currentPetId: String
    let petName: String
    let petPhoto: String
    let location: GeoPoint
    let status: Int
}
