//
//  Message.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/24.
//

import FirebaseFirestore

struct Message: Codable {
    
    var otherUserId: String
    let senderId: String
    let recieverId: String
    let content: String
    let createdTime: String
}

struct Conversation: Codable {
    
    let user: User
    let message: Message
}
