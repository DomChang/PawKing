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
    let likes: Int
    let commentsId: [String]
    let createdTime: Timestamp
}
