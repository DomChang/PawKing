//
//  PetManager.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/18.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import UIKit

class PetManager {
    
    static let shared = PetManager()
    
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
                    
                    self?.updateUserPet(userId: userId, petId: petId) { result in
                        
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
                            
                            MapManager.shared.updateUserLocation(location: userLocation) { result in
                                
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
    
    func fetchPetInfo(userId: String, petId: String, completion: @escaping (Result<Pet, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
            .collection(FirebaseCollection.pets.rawValue).document(petId)
            
        document.getDocument { snapshot, _ in
            
            guard let snapshot = snapshot
            
            else {
                
                    completion(.failure(FirebaseError.fetchPetError))
                    
                    return
            }
            
            do {
                
                let pet = try snapshot.data(as: Pet.self)
                
                completion(.success(pet))
                
            } catch {
                
                completion(.failure(FirebaseError.decodePetError))
            }
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
    
    func updatePetInfo(userId: String,
                       pet: Pet,
                       image: UIImage,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        
        uploadPetPhoto(userId: userId, petId: pet.id, image: image) { [weak self] result in
            switch result {
                
            case .success(let url):
                
                guard let self = self else { return }
                
                let document = self.dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
                    .collection(FirebaseCollection.pets.rawValue).document(pet.id)
                
                document.updateData([
                    "name": pet.name,
                    "gender": pet.gender,
                    "birthday": pet.birthday,
                    "petImage": url
                ]) { error in
                    
                    if let error = error {
                        
                        completion(.failure(error))
                        
                    } else {
                        
                        completion(.success(()))
                    }
                }
                
            case .failure(let error):
                
                print(error)
            }
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
                          pet: Pet) {
        
        let batch = dataBase.batch()
        
        let locationDoc = dataBase.collection(FirebaseCollection.userLocations.rawValue).document(userId)
        
        batch.updateData([
            "currentPetId": pet.id,
            "petPhoto": pet.petImage
        ], forDocument: locationDoc)
        
        let userDoc = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
        
        batch.updateData([
            "currentPetId": pet.id
        ], forDocument: userDoc)
        
        batch.commit()
    }
    
    func deletePet(userId: String,
                   petId: String,
                   completion: @escaping (Result<Void, Error>) -> Void) {
        
        let batch = dataBase.batch()
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dispatchQueue = DispatchQueue.global()
        
        dispatchQueue.async { [weak self] in
            
            guard let self = self else { return }
            
            let trackDoc = self.dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
                .collection(FirebaseCollection.tracks.rawValue).whereField("petId", isEqualTo: petId)
            
            trackDoc.getDocuments { snapshots, _ in
                
                    snapshots?.documents.forEach({ snapshot in
                        
                        batch.deleteDocument(snapshot.reference)
                        
                    })
                semaphore.signal()
            }
            semaphore.wait()
            
            let postDoc = self.dataBase.collection(FirebaseCollection.posts.rawValue)
                .whereField("petId", isEqualTo: petId)
            
            postDoc.getDocuments { snapshots, _ in
                
                    snapshots?.documents.forEach({ snapshot in
                        
                        batch.deleteDocument(snapshot.reference)
                        
                    })
                semaphore.signal()
            }
            semaphore.wait()
            
            let locationDoc = self.dataBase.collection(FirebaseCollection.userLocations.rawValue)
                .whereField("currentPetId", isEqualTo: petId)
            
            locationDoc.getDocuments { snapshots, _ in
                
                    snapshots?.documents.forEach({ snapshot in
                        
                        batch.updateData([
                            
                            "currentPetId": ""
                        
                        ], forDocument: snapshot.reference)
                        
                    })
                semaphore.signal()
            }
            semaphore.wait()
            
            let userDoc = self.dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
            
            batch.updateData([
                
                "petsId": FieldValue.arrayRemove([petId])
            
            ], forDocument: userDoc)
            
            let petDoc = self.dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
                .collection(FirebaseCollection.pets.rawValue).document(petId)
            
            batch.deleteDocument(petDoc)
            
            batch.commit { error in
                
                if let error = error {
                    
                    completion(.failure(error))
                } else {
                    
                    completion(.success(()))
                }
            }
        }
    }
}
