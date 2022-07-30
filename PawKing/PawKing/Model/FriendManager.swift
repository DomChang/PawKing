//
//  FriendManager.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/30.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

class FriendManager {
    
    static let shared = FriendManager()
    
    private lazy var dataBase = Firestore.firestore()
    
    func sendFriendRequest(senderId: String,
                           recieverId: String,
                           recieverBlockIds: [String],
                           completion: @escaping (Result<Void, Error>) -> Void) {
        
        let batch = dataBase.batch()
        
        let senderDoc = dataBase.collection(FirebaseCollection.users.rawValue).document(senderId)
        
        batch.updateData([
            "sendRequestsId": FieldValue.arrayUnion([recieverId])
        ], forDocument: senderDoc)
        
        if !recieverBlockIds.contains(senderId) {
            
            let recieverDoc = dataBase.collection(FirebaseCollection.users.rawValue).document(recieverId)
            
            batch.updateData([
                "recieveRequestsId": FieldValue.arrayUnion([senderId])
            ], forDocument: recieverDoc)
        }
        
        batch.commit(completion: { err in
            
            if let err = err {
                
                print("Error writing batch \(err)")
                
            } else {

                print("Batch write succeeded.")
            }
        })
    }
    
    func removeFriendRequest(senderId: String,
                             recieverId: String,
                             completion: @escaping (Result<Void, Error>) -> Void) {
        
        let batch = dataBase.batch()
        
        let senderDoc = dataBase.collection(FirebaseCollection.users.rawValue).document(senderId)
        
        batch.updateData([
            "sendRequestsId": FieldValue.arrayRemove([recieverId])
        ], forDocument: senderDoc)
        
        let recieverDoc = dataBase.collection(FirebaseCollection.users.rawValue).document(recieverId)
        
        batch.updateData([
            "recieveRequestsId": FieldValue.arrayRemove([senderId])
        ], forDocument: recieverDoc)
        
        batch.commit { err in
            
            if let err = err {
                
                completion(.failure(err))
                
            } else {
                
                completion(.success(()))
            }
        }
    }
    
    func denyFriendRequest(senderId: String,
                           userId: String,
                           completion: @escaping (Result<Void, Error>) -> Void) {
        
        let recieverDoc = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
        
        recieverDoc.updateData([
            
            "recieveRequestsId": FieldValue.arrayRemove([senderId])
            
        ]) { err in
            
            if let err = err {
                
                completion(.failure(err))
                
            } else {
                
                completion(.success(()))
            }
        }
    }
    
    func acceptFriendRequest(senderId: String,
                             userId: String,
                             completion: @escaping (Result<Void, Error>) -> Void) {
        
        let batch = dataBase.batch()
        
        let senderDoc = dataBase.collection(FirebaseCollection.users.rawValue).document(senderId)
        
        let userDoc = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
        
        batch.updateData([
            "friends": FieldValue.arrayUnion([userId])
        ], forDocument: senderDoc)
        
        batch.updateData([
            "friends": FieldValue.arrayUnion([senderId])
        ], forDocument: userDoc)
        
        batch.updateData([
            "sendRequestsId": FieldValue.arrayRemove([userId])
        ], forDocument: senderDoc)
        
        batch.updateData([
            "recieveRequestsId": FieldValue.arrayRemove([senderId])
        ], forDocument: userDoc)
        
        batch.commit { err in
            
            if let err = err {
                
                completion(.failure(err))
                
            } else {
                
                completion(.success(()))
            }
        }
    }
    
    func removeFriend(userId: String,
                      friendId: String,
                      completion: @escaping (Result<Void, Error>) -> Void) {
        
        let batch = dataBase.batch()
        
        let userDoc = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
        
        let friendDoc = dataBase.collection(FirebaseCollection.users.rawValue).document(friendId)
        
        batch.updateData([
            "friends": FieldValue.arrayRemove([friendId])
        ], forDocument: userDoc)
        
        batch.updateData([
            "friends": FieldValue.arrayRemove([userId])
        ], forDocument: friendDoc)
        
        batch.commit { err in
            
            if let err = err {
                
                completion(.failure(err))
                
            } else {
                
                completion(.success(()))
            }
        }
    }
}
