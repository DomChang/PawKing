//
//  MapManager.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/15.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

class MapManager {
    
    static let shared = MapManager()
    
    lazy var dataBase = Firestore.firestore()
    
    func uploadTrack(trackInfo: inout TrackInfo, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.tracks.rawValue).document()
        trackInfo.id = document.documentID
        trackInfo.endTime = Timestamp(date: Date())
        
        do {
            try document.setData(from: trackInfo)
            completion(.success(()))
            
        } catch {
            completion(.failure(FirebaseError.uploadTrackError))
        }
    }
    
    func updateUserLocation(location: UserLocation, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.userLocations.rawValue).document(location.userId)
        
        do {
            try document.setData(from: location)
            
            completion(.success(()))
            
        } catch {
            completion(.failure(FirebaseError.uploadTrackError))
        }
    }
    
    func changeUserStatus(userId: String, status: Status, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.userLocations.rawValue).document(userId)
            
        document.updateData([
            "status": status.rawValue
        ]) { error in
            print(error ?? "")
        }
    }
    
    func listenFriendsLocation(friend: String, completion: @escaping (Result<UserLocation, Error>) -> Void) {
    
        dataBase.collection(FirebaseCollection.userLocations.rawValue).document(friend).addSnapshotListener { snapshot, _ in
            
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
    
    func fetchAllUserLocations(completion: @escaping (Result<[UserLocation], Error>) -> Void) {
        
        var users: [UserLocation] = []
        
        let document = dataBase.collection(FirebaseCollection.userLocations.rawValue)
            
        document.getDocuments { snapshots, _ in
            
            guard let snapshots = snapshots
            
            else {
                    completion(.failure(FirebaseError.fetchUserError))
                    
                    return
            }
            
            do {
                
                for document in snapshots.documents {
                    
                    let user = try document.data(as: UserLocation.self)
                    
                    users.append(user)
                }
                
                completion(.success(users))
                
            } catch {
                
                completion(.failure(FirebaseError.decodeUserError))
            }
            
        }
    }
    
    func fetchStrangerLocations(friend: [String], completion: @escaping (Result<[UserLocation], Error>) -> Void) {
        
        var strangerLocations: [UserLocation] = []
        
        fetchAllUserLocations { result in
            switch result {
                
            case .success(let userLocations):
                
                for userLocation in userLocations {
                    
                    if !friend.contains(userLocation.userId) {
                        strangerLocations.append(userLocation)
                    }
                }
                completion(.success(strangerLocations))
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
}
