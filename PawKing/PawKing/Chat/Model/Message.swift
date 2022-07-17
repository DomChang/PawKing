//
//  Message.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/24.
//

import FirebaseFirestore

enum MessageStatus: Int {
    
    case notRead
    
    case isRead
}

struct Message: Codable {
    
    var otherUserId: String
    let senderId: String
    let recieverId: String
    let content: String
    let createdTime: Timestamp
    let isRead: Int
}

struct Conversation: Codable {
    
    let otherUser: User
    let message: Message
}
