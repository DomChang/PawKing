//
//  Pet.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/17.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

enum PetGender: String, CaseIterable {
    
    case male = "Boy"
    
    case female = "Girl"
    
    case other = "Other"
}

struct Pet: Codable {
    
    var id: String
    let ownerId: String
    let name: String
    let gender: Int
    let breed: String
    let description: String
    let birthday: Timestamp
    let createdTime: Timestamp
    var petImage: String
    let postsId: [String]
    let tracksId: [String]
    let personality: PetPersonality
}

struct PetPersonality: Codable {
    
    let isChildFriendly: Bool
    let isCatFriendly: Bool
    let isDogFriendly: Bool
}
