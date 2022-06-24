//
//  UserManager.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/17.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class UserManager {
    
//    static var userId: String?
    
    static let shared = UserManager()
    
    lazy var dataBase = Firestore.firestore()
    
    func setupUser(user: inout User, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document()
        user.id = document.documentID
        
        do {
            try document.setData(from: user)
            
            completion(.success(user.id))
            
            let id = Data(user.id.utf8)
            
            KeychainManager.shared.save(id,
                                        service: KeychainService.userId.rawValue,
                                        account: KeychainAccount.pawKing.rawValue)
            
        } catch {
            completion(.failure(FirebaseError.setupUserError))
        }
    }
    
    func updateUserInfo(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(user.id)
        
        do {
            try document.setData(from: user)
            
            completion(.success(()))
        } catch {
            completion(.failure(FirebaseError.setupUserError))
        }
    }
    
    func updateUserInfo(userId: String,
                        userName: String,
                        userDescription: String,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
        
        document.updateData([
            "name": userName,
            "description": userDescription
        ]) { error in
            
            if error != nil {
                
                completion(.failure(FirebaseError.updateUserInfoError))
                
            } else {
                
                completion(.success(()))
            }
        }
    }
    
    func updateUserPet(userId: String, petId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
        
        document.updateData([
            "petsId": FieldValue.arrayUnion([petId]),
            "currentPetId": petId
        ]) { error in
            
            if let error = error {
                
                completion(.failure(error))
                
            } else {
                
                completion(.success(()))
            }
        }
    }
    
    func updateCurrentPet(userId: String,
                          pet: Pet,
                          completion: @escaping (Result<Void, Error>) -> Void) {
        
        let locationDoc = dataBase.collection(FirebaseCollection.userLocations.rawValue).document(userId)
        
        locationDoc.updateData([
            
            "currentPetId": pet.id,
            "petPhoto": pet.petImage
        ]) { [weak self] error in
            
            if let error = error {
                
                completion(.failure(error))
                
            } else {
                
                let userDoc = self?.dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
                
                userDoc?.updateData([
                    
                    "currentPetId": pet.id
                ]) { error in
                    
                    if let error = error {
                        
                        completion(.failure(error))
                        
                    } else {
                        
                        completion(.success(()))
                    }
                }
            }
        }
    }
    
    func fetchUserInfo(userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
            
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
    
    func fetchUserLocation(userId: String, completion: @escaping (Result<UserLocation, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.userLocations.rawValue).document(userId)
            
        document.getDocument { snapshot, _ in
            
            guard let snapshot = snapshot
            
            else {
                    completion(.failure(FirebaseError.fetchUserError))
                    
                    return
            }
            
            do {
                
                let userLocation = try snapshot.data(as: UserLocation.self)
                
                completion(.success(userLocation))
                
            } catch {
                
                completion(.failure(FirebaseError.decodeUserError))
            }
            
        }
    }
    
    func fetchTracks(userId: String, completion: @escaping (Result<[TrackInfo], Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
            .collection(FirebaseCollection.tracks.rawValue).order(by: "startTime", descending: true)
            
        document.getDocuments { snapshots, _ in
            
            var trackInfos: [TrackInfo] = []
            
            guard let snapshots = snapshots
            
            else {
                    completion(.failure(FirebaseError.fetchTrackError))
                    
                    return
            }
            
            do {
                
                for document in snapshots.documents {
                    
                    let trackInfo = try document.data(as: TrackInfo.self)
                    
                    trackInfos.append(trackInfo)
                }
                
                completion(.success(trackInfos))
                
            } catch {
                
                completion(.failure(FirebaseError.decodeTrackError))
            }
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
    
    func fetchPets(userId: String, completion: @escaping (Result<[Pet], Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
            .collection(FirebaseCollection.pets.rawValue).order(by: "createdTime", descending: true)
            
        document.getDocuments { snapshots, _ in
            
            var pets: [Pet] = []
            
            guard let snapshots = snapshots
            
            else {
                    completion(.failure(FirebaseError.fetchPetError))
                    
                    return
            }
            
            do {
                
                for document in snapshots.documents {
                    
                    let pet = try document.data(as: Pet.self)
                    
                    pets.append(pet)
                }
                
                completion(.success(pets))
                
            } catch {
                
                completion(.failure(FirebaseError.decodePetError))
            }
        }
    }
    
    func listenPetChange(userId: String, completion: @escaping (Result<[Pet], Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
            .collection(FirebaseCollection.pets.rawValue).order(by: "createdTime", descending: true)
            
        document.addSnapshotListener { snapshots, _ in
            
            var pets: [Pet] = []
            
            guard let snapshots = snapshots
            
            else {
                    completion(.failure(FirebaseError.fetchUserError))
                    
                    return
            }
            
            do {
                
                for document in snapshots.documents {
                    
                    let pet = try document.data(as: Pet.self)
                    
                    pets.append(pet)
                }
                
                completion(.success(pets))
                
            } catch {
                
                completion(.failure(FirebaseError.decodeUserError))
            }
        }
    }
    
    func uploadUserPhoto(userId: String, image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
            
        let fileReference = Storage.storage().reference().child("userImages/\(userId).jpg")
    
        if let data = image.jpegData(compressionQuality: 0.3) {
            
            fileReference.putData(data, metadata: nil) { [weak self] result in
                
                switch result {
                    
                case .success:
                    
                    fileReference.downloadURL { result in
                        
                        switch result {
                            
                        case .success(let url):
                            
                            let document = self?.dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
                            
                            let userImageUrlString = String(describing: url)
                            
                            document?.updateData([
                                
                                "userImage": userImageUrlString
                                
                            ]) { error in
                                
                                if error != nil {
                                    
                                    completion(.failure(FirebaseError.uploadUserPhotoError))
                                    
                                } else {
                                    
                                    completion(.success(()))
                                }
                            }
                            
                        case .failure:
                            
                            completion(.failure(FirebaseError.uploadUserPhotoError))
                        }
                    }
                case .failure:
                    
                    completion(.failure(FirebaseError.uploadUserPhotoError))
                }
            }
        }
    }
    
    func fetchAllUser(completion: @escaping (Result<[User], Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue)
            
        document.getDocuments { snapshots, _ in
            
            var users: [User] = []
            
            guard let snapshots = snapshots
            
            else {
                    completion(.failure(FirebaseError.fetchUserError))
                    
                    return
            }
            
            do {
                
                for document in snapshots.documents {
                    
                    let user = try document.data(as: User.self)
                    
                    users.append(user)
                }
                
                completion(.success(users))
                
            } catch {
                
                completion(.failure(FirebaseError.decodeUserError))
            }
        }
    }
}
