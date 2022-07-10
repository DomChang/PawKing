//
//  User.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/16.
//

import Foundation

enum UserStatus: String {
    
    case unknown
}

struct User: Codable {
    
    var id: String
    var name: String
    var petsId: [String]
    var currentPetId: String
    var userImage: String
    var description: String
    let friendPetsId: [String]
    var friends: [String]
    var recieveRequestsId: [String]
    var sendRequestsId: [String]
    var blockUsersId: [String]
}
