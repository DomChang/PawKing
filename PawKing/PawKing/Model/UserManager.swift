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
    
    func updateUserPet(userId: String, petId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
        
        document.updateData([
            "petsId": FieldValue.arrayUnion([petId])
        ]) { error in
            
            if let error = error {
                
                completion(.failure(error))
                
            } else {
                
                completion(.success(()))
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
    
    func updateUserLocation(location: UserLocation, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.userLocations.rawValue).document(location.userId)
        
        do {
            try document.setData(from: location)
            
            completion(.success(()))
            
        } catch {
            completion(.failure(FirebaseError.uploadTrackError))
        }
    }
    
    // 查詢陌生人寵物使用
    func fetchPetsbyUser(user: String, completion: @escaping (Result<[Pet], Error>) -> Void) {
        
        var pets: [Pet] = []
        
        let document = dataBase.collection(FirebaseCollection.pets.rawValue).whereField("ownerId", isEqualTo: user)
            
        document.getDocuments { snapshots, _ in
            
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
    
    func uploadUserPhoto(userId: String, image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
            
        let fileReference = Storage.storage().reference().child("userImages/\(userId).jpg")
    
        if let data = image.jpegData(compressionQuality: 1) {
            
            fileReference.putData(data, metadata: nil) { result in
                
                switch result {
                    
                case .success:
                    
                     fileReference.downloadURL(completion: completion)
                    
                case .failure(let error):
                    
                    completion(.failure(error))
                }
            }
        }
    }
}
