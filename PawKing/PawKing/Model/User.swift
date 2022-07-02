//
//  User.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/16.
//

import Foundation

struct User: Codable {
    
    var id: String
    var name: String
    var petsId: [String]
    var currentPetId: String
    var userImage: String
    var description: String
    let friendPetsId: [String]
    var friends: [String]
    var recieveFriendRequest: [String]
    var sendRequestsId: [String]
}
