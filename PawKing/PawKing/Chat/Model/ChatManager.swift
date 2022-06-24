//
//  ChatManager.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/24.
//

import FirebaseFirestore

class ChatManager {
    
    static let shared = ChatManager()
    
    lazy var dataBase = Firestore.firestore()
    
    private let userManager = UserManager.shared
    
    func sendMessage(message: Message,
                       completion: @escaping (Result<Void, Error>) -> Void) {
            
        let batch = dataBase.batch()
        
        var userMessage = message
        
        userMessage.otherUserId = message.recieverId
        
        let senderRef = dataBase.collection(FirebaseCollection.chats.rawValue).document(userMessage.senderId)
            .collection(message.recieverId).document()
        
        do {
            try batch.setData(from: message, forDocument: senderRef)
        } catch {
            completion(.failure(FirebaseError.sendMessageError))
        }
        
        var recieverMessage = message
        
        recieverMessage.otherUserId = message.senderId
        
        let recieverRef = dataBase.collection(FirebaseCollection.chats.rawValue).document(recieverMessage.recieverId)
            .collection(message.senderId).document()
        
        do {
            try batch.setData(from: message, forDocument: recieverRef)
        } catch {
            completion(.failure(FirebaseError.sendMessageError))
        }
        
        let senderRecentRef = dataBase.collection(FirebaseCollection.chats.rawValue).document(message.senderId)
            .collection(FirebaseCollection.recentMessages.rawValue).document(message.recieverId)
        
        do {
            try batch.setData(from: userMessage, forDocument: senderRecentRef)
        } catch {
            completion(.failure(FirebaseError.sendMessageError))
        }
        
        let recieveRecentRef = dataBase.collection(FirebaseCollection.chats.rawValue).document(message.recieverId)
            .collection(FirebaseCollection.recentMessages.rawValue).document(message.senderId)
        
        do {
            try batch.setData(from: recieverMessage, forDocument: recieveRecentRef)
        } catch {
            completion(.failure(FirebaseError.sendMessageError))
        }
        
        batch.commit() { err in
            if err != nil {
                completion(.failure(FirebaseError.sendMessageError))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchChatRooms(userId: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {

        let document = dataBase.collection(FirebaseCollection.chats.rawValue).document(userId)
            .collection(FirebaseCollection.recentMessages.rawValue)

        document.getDocuments { [weak self] snapshots, _ in

            var chatRooms: [Conversation] = []
            
            guard let snapshots = snapshots

            else {
                    completion(.failure(FirebaseError.fetchMessageError))

                    return
            }
            
            let semaphore = DispatchSemaphore(value: 1)
            
            let dispatchQueue = DispatchQueue.global()
            
            dispatchQueue.async { [weak self] in
                
                do {

                    for document in snapshots.documents {
                        
                        semaphore.wait()

                        let chat = try document.data(as: Message.self)
                        
                        let otherUserId = chat.otherUserId
                        
                        self?.userManager.fetchUserInfo(userId: otherUserId) { result in
                            
                            switch result {
                                
                            case.success(let user):
                                
                                chatRooms.append(Conversation(user: user, message: chat))
                                
                            case .failure:
                                
                                semaphore.signal()
                             
                                completion(.failure(FirebaseError.fetchUserError))
                            }
                        }
                    }
                    completion(.success(chatRooms))

                } catch {

                    completion(.failure(FirebaseError.decodeMessageError))
                }
                
            }
        }
    }
}
