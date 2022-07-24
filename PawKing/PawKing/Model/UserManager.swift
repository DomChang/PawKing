//
//  UserManager.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/17.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseAuth

// swiftlint:disable file_length

class UserManager {
    
    static let shared = UserManager()
    
    var currentUser: User? {
        didSet {
            NotificationCenter.default.post(name: .updateUser, object: .none)
        }
    }
    
    var guestUser = User(id: UserStatus.guest.rawValue,
                         name: "Guest",
                         petsId: [],
                         currentPetId: "",
                         userImage: "",
                         description: "",
                         friendPetsId: [],
                         friends: [],
                         recieveRequestsId: [],
                         sendRequestsId: [],
                         blockUsersId: [])
    
    private lazy var dataBase = Firestore.firestore()
    
    func checkUserExist(uid: String, completion: @escaping (Bool) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(uid)
            
        document.getDocument { snapshot, _ in
            
            guard snapshot?.data() != nil
            
            else {
                    completion(false)
                    
                    return
            }
            completion(true)
        }
    }
    
    func setupUser(user: User, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(user.id)
        
        do {
            try document.setData(from: user)
            
            completion(.success(user.id))
            
        } catch {
            completion(.failure(FirebaseError.setupUserError))
        }
    }
    
    func updateUserInfo(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(user.id)
        
        do {
            try document.setData(from: user)
            
            self.currentUser = user
            
            completion(.success(()))
        } catch {
            completion(.failure(FirebaseError.setupUserError))
        }
    }
    
    func updateUserInfo(userId: String,
                        userName: String,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
        
        document.updateData([
            "name": userName
        ]) { error in
            
            if error != nil {
                
                completion(.failure(FirebaseError.updateUserInfoError))
                
            } else {
                
                completion(.success(()))
                
//                UserManager.shared.currentUser?.name = userName
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
                
//                UserManager.shared.currentUser?.petsId.append(petId)
//                UserManager.shared.currentUser?.currentPetId = petId
                
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
                        
//                        UserManager.shared.currentUser?.currentPetId = pet.id
                        
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
    
    func listenUserInfo(userId: String, completion: @escaping (Result<User, Error>) -> Void) -> ListenerRegistration {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
            
        let listener = document.addSnapshotListener { snapshot, _ in
            
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
        
        return listener
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
                                    
//                                    UserManager.shared.currentUser?.userImage = userImageUrlString
                                    
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
    
    func fetchUsers(userIds: [String], completion: @escaping (Result<([User], [String]), Error>) -> Void) {
        
        var users: [User] = []
        
        var deletedUsersId: [String] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dispatchQueue = DispatchQueue.global()
        
        dispatchQueue.async { [weak self] in
            
            for userId in userIds {
                
                let document = self?.dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
                
                document?.getDocument { snapshot, _ in
                    
                    guard let snapshot = snapshot
                    
                    else {
                        
                            completion(.failure(FirebaseError.fetchUserError))
                            
                            return
                    }
                    
                    do {
                        
                        let user = try snapshot.data(as: User.self)
                        
                        if user.id != UserStatus.unknown.rawValue {
                            
                            users.append(user)
                        } else {
                            
                            deletedUsersId.append(userId)
                        }
                        semaphore.signal()
                        
                    } catch {
                        
                        completion(.failure(FirebaseError.decodeUserError))
                    }
                }
                semaphore.wait()
            }
            completion(.success((users, deletedUsersId)))
        }
    }
    
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
                
//                UserManager.shared.currentUser?.sendRequestsId.append(recieverId)
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
                
//                UserManager.shared.currentUser?.sendRequestsId.removeAll(where: { $0 == recieverId })
                
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
                
//                UserManager.shared.currentUser?.recieveRequestsId.removeAll(where: { $0 == senderId })
                
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
                
//                UserManager.shared.currentUser?.recieveRequestsId.removeAll(where: { $0 == senderId })
//                UserManager.shared.currentUser?.friends.append(senderId)
                
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
                
//                UserManager.shared.currentUser?.friends.removeAll(where: { $0 == friendId })
                
                completion(.success(()))
            }
        }
    }
    
    func addBlockUser(userId: String, blockId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let batch = dataBase.batch()
        
        let userDoc = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
        
        batch.updateData([
            
            "blockUsersId": FieldValue.arrayUnion([blockId]),
            "recieveRequestsId": FieldValue.arrayRemove([blockId]),
            "sendRequestsId": FieldValue.arrayRemove([blockId]),
            "friends": FieldValue.arrayRemove([blockId])
            
        ], forDocument: userDoc)
        
        let blockDoc = dataBase.collection(FirebaseCollection.users.rawValue).document(blockId)
        
        batch.updateData([
            
            "recieveRequestsId": FieldValue.arrayRemove([userId]),
            "friends": FieldValue.arrayRemove([userId])
            
        ], forDocument: blockDoc)
        
        batch.commit { error in
            
            if let error = error {
                
                completion(.failure(error))
                
            } else {
                
                completion(.success(()))
            }
        }
    }
        
    func removeBlockUser(userId: String, blockId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
        
        document.updateData([
            
            "blockUsersId": FieldValue.arrayRemove([blockId])
            
        ]) { error in
            
            if let error = error {
                
                completion(.failure(error))
                
            } else {
                
//                UserManager.shared.currentUser?.blockUsersId.removeAll(where: {$0 == blockId})
                
                completion(.success(()))
            }
        }
    }
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()

            UserManager.shared.currentUser =  User(id: "Guest",
                                                     name: "Guest",
                                                     petsId: [],
                                                     currentPetId: "",
                                                     userImage: "",
                                                     description: "",
                                                     friendPetsId: [],
                                                     friends: [],
                                                     recieveRequestsId: [],
                                                     sendRequestsId: [],
                                                     blockUsersId: [])

            Auth.auth().currentUser?.reload()

            completion(.success(()))

        } catch let signOutError {
            
            completion(.failure(signOutError))
        }
    }
    
    func deleteUser(userId: String,
                    completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let user = currentUser else { return }
        
        let friends = user.friends
        
        let batch = dataBase.batch()
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dispatchQueue = DispatchQueue.global()
        
        dispatchQueue.async { [weak self] in
        
            Auth.auth().currentUser?.delete(completion: { error in

                if let error = error {

                completion(.failure(error))

                } else {
                    
                    semaphore.signal()
                }
            })
            semaphore.wait()
            
            friends.forEach { friendId in
                
                if let friendDoc = self?.dataBase.collection(FirebaseCollection.users.rawValue).document(friendId) {
                    
                    batch.updateData([
                        
                        "friends": FieldValue.arrayRemove([userId])
                    
                    ], forDocument: friendDoc)
                    
                    semaphore.signal()
                }
                semaphore.wait()
            }
            
            if let postDoc = self?.dataBase.collection(FirebaseCollection.posts.rawValue)
                .whereField("userId", isEqualTo: userId) {
                
                postDoc.getDocuments { snapshots, _ in
                    
                        snapshots?.documents.forEach({ snapshot in
                            
                            batch.deleteDocument(snapshot.reference)
                            
                        })
                    semaphore.signal()
                }
            }
            semaphore.wait()
            
            let userDoc = self?.dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
            
            let unkownUser = User(id: "unknown",
                            name: "Unknown",
                            petsId: [],
                            currentPetId: "",
                            userImage: "",
                            description: "",
                            friendPetsId: [],
                            friends: [],
                            recieveRequestsId: [],
                            sendRequestsId: [],
                            blockUsersId: [])
            
            do {
                if let userDoc = userDoc {
                    try batch.setData(from: unkownUser, forDocument: userDoc)
                }
            } catch {
                completion(.failure(FirebaseError.deleteUserError))
            }
            
            if let userLocationDoc = self?.dataBase.collection(FirebaseCollection.userLocations.rawValue)
                .document(userId) {
                
                batch.deleteDocument(userLocationDoc)
            }
            
            batch.commit { error in
                if error != nil {
                    
                    completion(.failure(FirebaseError.deleteUserError))
                } else {
                    
                    Auth.auth().currentUser?.reload()
                    completion(.success(()))
                }
            }
        }
    }
}

// swiftlint:enable file_length
