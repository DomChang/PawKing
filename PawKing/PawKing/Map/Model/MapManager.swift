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
    
    func uploadTrack(userId: String, trackInfo: inout TrackInfo, completion: @escaping (Result<TrackInfo, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
                        .collection(FirebaseCollection.tracks.rawValue).document()
        
        trackInfo.id = document.documentID
        trackInfo.endTime = Timestamp(date: Date())
        
        do {
            try document.setData(from: trackInfo)
            completion(.success(trackInfo))
            
        } catch {
            completion(.failure(FirebaseError.uploadTrackError))
        }
    }
    
    func updateTrackNote(userId: String,
                         trackInfo: TrackInfo,
                         trackNote: String,
                         completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
            .collection(FirebaseCollection.tracks.rawValue).document(trackInfo.id)
        
        document.updateData([
            "note": trackNote
        ]) { error in
            
            if error != nil {
                
                completion(.failure(FirebaseError.uploadTrackError))
                
            } else {
                
                completion(.success(()))
            }
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
    
    func listenFriendsLocation(friend: String, completion: @escaping (Result<UserLocation, Error>) -> Void) -> ListenerRegistration {
    
        let listener = dataBase.collection(FirebaseCollection.userLocations.rawValue).document(friend)
                .addSnapshotListener { snapshot, _ in
            
            guard let snapshot = snapshot else {
                
                completion(.failure(FirebaseError.fetchFriendError))
                return
            }
            
            do {
                
                let friend = try snapshot.data(as: UserLocation.self)
                
                completion(.success(friend))
                
            } catch {
                
                completion(.failure(FirebaseError.decodeUserError))
            }
        }
        
        return listener
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
    
    func fetchStrangerLocations(friend: [String], blockIds: [String], completion: @escaping (Result<[UserLocation], Error>) -> Void) {
        
        var strangerLocations: [UserLocation] = []
        
        fetchAllUserLocations { result in
            switch result {
                
            case .success(let userLocations):
                
                for userLocation in userLocations {
                    
                    if !friend.contains(userLocation.userId) && !blockIds.contains(userLocation.userId) {
                        strangerLocations.append(userLocation)
                    }
                }
                completion(.success(strangerLocations))
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func deleteTrack(userId: String, petId: String, trackId:String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let batch = dataBase.batch()
        
        let trackDoc = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
            .collection(FirebaseCollection.tracks.rawValue).document(trackId)
        
        batch.deleteDocument(trackDoc)
        
        let petDoc = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
            .collection(FirebaseCollection.pets.rawValue).document(petId)
        
        batch.updateData([
            
            "tracksId": FieldValue.arrayRemove([trackId])
        
        ], forDocument: petDoc)
        
        batch.commit { error in
            if let error = error {
                
                completion(.failure(error))
                
            } else {
                
                completion(.success(()))
            }
        }
    }
}
