//
//  PetManager.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/18.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class PetManager {
    
    static let shared = PetManager()
    
    private let userManager = UserManager.shared
    
    lazy var dataBase = Firestore.firestore()
    
    func setupPet(userId: String,
                  pet: inout Pet,
                  petName: String,
                  petImage: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
                       .collection(FirebaseCollection.pets.rawValue).document()
        
        pet.id = document.documentID
        
        do {
            try document.setData(from: pet)
            
            let petId = document.documentID
            
            uploadPetPhoto(userId: userId, petId: petId, image: petImage) { [weak self] result in
                
                switch result {
                    
                case .success(let petImageUrlString):
                    
                    self?.userManager.updateUserPet(userId: userId, petId: petId) { result in
                        
                        switch result {
                            
                        case .success:
                            
                            let userLocation = UserLocation(userId: userId,
                                                            userName: "",
                                                            userPhoto: "",
                                                            currentPetId: document.documentID,
                                                            petName: petName,
                                                            petPhoto: petImageUrlString,
                                                            location: GeoPoint(latitude: 0, longitude: 0),
                                                            status: 0)
                            
                            self?.userManager.updateUserLocation(location: userLocation) { result in
                                
                                switch result {
                                    
                                case .success:
                                    
                                    completion(.success(()))
                                    
                                case .failure:
                                    
                                    completion(.failure(FirebaseError.setupPetError))
                                }
                            }
                            
                        case .failure:
                            
                            completion(.failure(FirebaseError.setupPetError))
                        }
                    }
                    
                case .failure:
                    
                    completion(.failure(FirebaseError.setupPetError))
                }
            }
        } catch {
            completion(.failure(FirebaseError.setupPetError))
        }
    }
    
    func updatePetInfo(userId: String,
                       pet: Pet,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
            .collection(FirebaseCollection.pets.rawValue).document(pet.id)
        
        do {
            try document.setData(from: pet)
            
            completion(.success(()))
            
        } catch {
            completion(.failure(FirebaseError.setupUserError))
        }
    }
    
    func uploadPetPhoto(userId: String,
                        petId: String,
                        image: UIImage,
                        completion: @escaping (Result<String, Error>) -> Void) {
            
        let fileReference = Storage.storage().reference().child("petImages/\(petId).jpg")
    
        if let data = image.jpegData(compressionQuality: 0.3) {
            
            fileReference.putData(data, metadata: nil) { [weak self] result in
                
                switch result {
                    
                case .success:
                    
                    fileReference.downloadURL { result in
                        
                        switch result {
                            
                        case .success(let url):
                            
                            let document = self?.dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
                                .collection(FirebaseCollection.pets.rawValue).document(petId)
                            
                            let petImageUrlString = String(describing: url)
                            
                            document?.updateData([
                                
                                "petImage": petImageUrlString
                                
                            ]) { error in
                                
                                if let error = error {
                                    
                                    completion(.failure(error))
                                    
                                } else {
                                    
                                    completion(.success(petImageUrlString))
                                }
                            }
                            
                        case .failure(let error):
                            
                            completion(.failure(error))
                        }
                    }
                    
                case .failure(let error):
                    
                    completion(.failure(error))
                }
            }
        }
    }
}
