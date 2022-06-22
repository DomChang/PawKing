//
//  Post.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/19.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct Post: Codable {
    
    var id: String
    let userId: String
    let petId: String
    let photo: String
    let caption: String
    let likesId: [String]
    let commentsId: [String]
    let createdTime: Timestamp
}

struct Comment: Codable {
    
    var id: String
    let postId: String
    let senderId: String
    let text: String
    let createdTime: Timestamp
}

struct Like: Codable {
    
    var id: String
    let postId: String
    let senderId: String
    let createdTime: Timestamp
}
