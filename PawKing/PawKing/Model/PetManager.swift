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
    
    lazy var dataBase = Firestore.firestore()
    
    func setupPet(pet: inout Pet, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.pets.rawValue).document()
        pet.id = document.documentID
        
        do {
            try document.setData(from: pet)
            
            completion(.success(pet.id))
            
        } catch {
            completion(.failure(FirebaseError.setupPetError))
        }
    }
    
    func updatePetInfo(pet: Pet, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.pets.rawValue).document(pet.id)
        
        do {
            try document.setData(from: pet)
            
            completion(.success(()))
        } catch {
            completion(.failure(FirebaseError.setupUserError))
        }
    }
    
    func uploadPetPhoto(petId: String, image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
            
        let fileReference = Storage.storage().reference().child("petImages/\(petId).jpg")
    
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
