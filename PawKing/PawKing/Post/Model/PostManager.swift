//
//  PostManager.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/20.
//

import Foundation

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class PostManager {
    
    static let shared = PostManager()
    
    lazy var dataBase = Firestore.firestore()

    func setupPost(userId: String,
                   petId: String,
                   post: inout Post,
                   postImage: UIImage,
                   completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
                       .collection(FirebaseCollection.posts.rawValue).document()
        
        post.id = document.documentID
        
        do {
            try document.setData(from: post)
            
            let postId = document.documentID
            
            uploadPostPhoto(userId: userId, postId: postId, image: postImage) { [weak self] result in
                
                switch result {
                    
                case .success:
                    
                    self?.updatePetPost(userId: userId, petId: petId, postId: postId) { result in
                        
                        switch result {
                            
                        case .success:
                            
                            completion(.success(()))
                            
                        case .failure:
                            
                            completion(.failure(FirebaseError.setupPostError))
                        }
                    }
                    
                case .failure:
                    
                    completion(.failure(FirebaseError.setupPostError))
                }
            }
        } catch {
            
            completion(.failure(FirebaseError.setupPostError))
        }
    }
    
    func fetchPostsbyUser(userId: String, completion: @escaping (Result<[Post], Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
            .collection(FirebaseCollection.posts.rawValue).order(by: "createdTime", descending: true)
            
        document.getDocuments { snapshots, _ in
            
            var posts: [Post] = []
            
            guard let snapshots = snapshots
            
            else {
                    completion(.failure(FirebaseError.fetchPostError))
                    
                    return
            }
            
            do {
                
                for document in snapshots.documents {
                    
                    let post = try document.data(as: Post.self)
                    
                    posts.append(post)
                }
                
                completion(.success(posts))
                
            } catch {
                
                completion(.failure(FirebaseError.decodePostError))
            }
        }
    }
    
    func updatePetPost(userId: String,
                       petId: String,
                       postId: String,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
            .collection(FirebaseCollection.pets.rawValue).document(petId)
        
        document.updateData([
            "postsId": FieldValue.arrayUnion([postId])
        ]) { error in
            
            if let error = error {
                
                completion(.failure(error))
                
            } else {
                
                completion(.success(()))
            }
        }
    }
    
    func uploadPostPhoto(userId: String,
                        postId: String,
                        image: UIImage,
                        completion: @escaping (Result<Void, Error>) -> Void) {
            
        let fileReference = Storage.storage().reference().child("postImages/\(NSUUID().uuidString).jpg")
    
        if let data = image.jpegData(compressionQuality: 0.3) {
            
            fileReference.putData(data, metadata: nil) { [weak self] result in
                
                switch result {
                    
                case .success:
                    
                    fileReference.downloadURL { result in
                        
                        switch result {
                            
                        case .success(let url):
                            
                            let document = self?.dataBase.collection(FirebaseCollection.users.rawValue).document(userId)
                                .collection(FirebaseCollection.posts.rawValue).document(postId)
                            
                            let postImageUrlString = String(describing: url)
                            
                            document?.updateData([
                                
                                "photo": postImageUrlString
                                
                            ]) { error in
                                
                                if let error = error {
                                    
                                    completion(.failure(error))
                                    
                                } else {
                                    
                                    completion(.success(()))
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
