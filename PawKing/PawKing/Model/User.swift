//
//  User.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/16.
//

import Foundation


struct User: Codable {
    
    var id: String
    let name: String
    let petsId: [String]
    let currentPetId: String
    var userImage: String
    let description: String
    let friendPetsId: [String]
    let friends: [String]
    let recieveFriendRequest: [String]
    let sendRequestsId: [String]
}
