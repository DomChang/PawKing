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
    
    static let shared = UserManager()
    
    lazy var dataBase = Firestore.firestore()
    
    func setupUser(user: inout User, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document()
        user.id = document.documentID
        
        do {
            try document.setData(from: user)
            
        } catch {
            completion(.failure(FirebaseError.setupUserError))
        }
    }
    
    func setupPet(pet: inout Pet, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.pets.rawValue).document()
        pet.id = document.documentID
        
        do {
            try document.setData(from: pet)
            
        } catch {
            completion(.failure(FirebaseError.setupUserError))
        }
    }
    
    func updateUserInfo(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(user.id)
        
        do {
            try document.setData(from: user)
        } catch {
            completion(.failure(FirebaseError.setupUserError))
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
    
    func fetchPetsbyUser(user: String, completion: @escaping (Result<[Pet], Error>) -> Void) {
        
        var pets: [Pet] = []
        
        let document = dataBase.collection(FirebaseCollection.pets.rawValue)
            
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
    
    func uploadPhoto(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
            
            let fileReference = Storage.storage().reference().child(UUID().uuidString + ".jpg")
        
            if let data = image.jpegData(compressionQuality: 0.9) {
                
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
