//
//  MapManager.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/15.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

class MapManager {
    
    lazy var dataBase = Firestore.firestore()
    
    func setupUser(user: inout User, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection("Users").document()
        user.id = document.documentID
        
        do {
            try document.setData(from: user)
            
        } catch {
            completion(.failure(FirebaseError.setupUserError))
        }
    }
    
    func updateUserInfo(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection("Users").document(user.id)
        
        do {
            try document.setData(from: user)
        } catch {
            completion(.failure(FirebaseError.setupUserError))
        }
    }
    
    func uploadTrack(trackInfo: inout TrackInfo, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection("tracks").document()
        trackInfo.id = document.documentID
        trackInfo.endTime = Timestamp(date: Date())
        
        do {
            try document.setData(from: trackInfo)
            completion(.success(()))
            
        } catch {
            completion(.failure(FirebaseError.uploadTrackError))
        }
    }
    
    func updateUserLocation(location: UserLocation,
                               completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection("UserLocations").document(location.userId)
        
        do {
            try document.setData(from: location)
            
            completion(.success(()))
            
        } catch {
            completion(.failure(FirebaseError.uploadTrackError))
        }
    }
    
    func changeUserStatus(userId: String, status: Status,
                             completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection("UserLocations").document(userId)
            
        document.updateData([
            "status": status.rawValue
        ]) { error in
            print(error ?? "")
        }
    }
    
    func fetchUserInfo(userId: String,
                             completion: @escaping (Result<User, Error>) -> Void) {
        
        let document = dataBase.collection("Users").document(userId)
            
        document.getDocument { snapshot, _ in
            
            guard let snapshot = snapshot
            
            else {
                    completion(.failure(FirebaseError.fetchUserError))
                    
                    return
            }
            
            do {
                
                let user = try snapshot.data(as: User.self)
                
                completion(.success(user))
                
            } catch {
                
                completion(.failure(FirebaseError.decodeUserError))
            }
            
        }
    }
    
    func listenFriendsLocation(friend: String, completion: @escaping (Result<UserLocation, Error>) -> Void) {
    
        dataBase.collection("UserLocations").document(friend).addSnapshotListener { snapshot, error in
            
            guard let snapshot = snapshot else {
                completion(.failure(FirebaseError.fetchFriendError))
                return
            }
            
            do {
                
                let friend = try snapshot.data(as: UserLocation.self)
                
                if friend.status == Status.tracking.rawValue {
                    completion(.success(friend))
                    
                } else {
                    
                    return
                }
            } catch {
                
                completion(.failure(FirebaseError.decodeUserError))
            }
        }
    }
}
