//
//  ChatManager.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/24.
//

import FirebaseFirestore

class ChatManager {
    
    static let shared = ChatManager()
    
    var chatRooms: [Conversation]? {
        didSet {
            NotificationCenter.default.post(name: .updateChatRooms, object: .none)
        }
    }
    
    lazy var dataBase = Firestore.firestore()
    
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
        
        batch.commit { err in
            if err != nil {
                completion(.failure(FirebaseError.sendMessageError))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func listenChatRooms(userId: String,
                         blockIds: [String],
                         completion: @escaping (Result<[Conversation], Error>) -> Void) -> ListenerRegistration {

        let document = dataBase.collection(FirebaseCollection.chats.rawValue).document(userId)
            .collection(FirebaseCollection.recentMessages.rawValue)

        let listener = document.addSnapshotListener { snapshots, _ in

            var chatRooms: [Conversation] = []
            
            guard let snapshots = snapshots

            else {
                    completion(.failure(FirebaseError.fetchMessageError))

                    return
            }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            let dispatchQueue = DispatchQueue.global()
            
            dispatchQueue.async {
                do {

                    for document in snapshots.documents {

                        let chat = try document.data(as: Message.self)
                        
                        let otherUserId = chat.otherUserId
                        
                        if !blockIds.contains(otherUserId) {
                            
                            UserManager.shared.fetchUserInfo(userId: otherUserId) { result in
                                
                                switch result {
                                    
                                case.success(let user):
                                    
                                    chatRooms.append(Conversation(otherUser: user, message: chat))

                                    semaphore.signal()
                                    
                                case .failure:
                                    
                                    completion(.failure(FirebaseError.fetchUserError))
                                }
                            }
                        }
                        semaphore.wait()
                    }
                    
                    chatRooms.sort { $0.message.createdTime.dateValue() > $1.message.createdTime.dateValue() }
                    completion(.success(chatRooms))
                    
                } catch {

                    completion(.failure(FirebaseError.decodeMessageError))
                }
            }
        }
        return listener
    }
    
    func fetchMessageHistory(user: User,
                             otherUser: User,
                             otherUserId: String,
                             completion: @escaping (Result<[Message], Error>) -> Void) {
        
        let document = dataBase.collection(FirebaseCollection.chats.rawValue).document(user.id)
            .collection(otherUserId).order(by: "createdTime", descending: false)
        
        document.getDocuments { snapshots, _ in

            var messages: [Message] = []
            
            guard let snapshots = snapshots

            else {
                    completion(.failure(FirebaseError.fetchMessageError))

                    return
            }
                
            do {

                for document in snapshots.documents {

                    let message = try document.data(as: Message.self)

                    messages.append(message)
                
                }
                
                completion(.success(messages))

            } catch {

                completion(.failure(FirebaseError.decodeMessageError))
            }
        }
    }
    
    func listenNewMessage(user: User,
                          otherUser: User,
                          completion: @escaping (Result<[Message], Error>) -> Void) -> ListenerRegistration {
        
        let document = dataBase.collection(FirebaseCollection.chats.rawValue).document(user.id)
            .collection(otherUser.id).order(by: "createdTime", descending: false)
        
        let listener = document.addSnapshotListener { snapshots, _ in
            
            var messages: [Message] = []
            
            guard let snapshots = snapshots
            
            else {
                    completion(.failure(FirebaseError.fetchMessageError))
                    
                    return
            }
            
            do {

                for diff in snapshots.documentChanges where diff.type == .added {
                        
                    let message = try diff.document.data(as: Message.self)
                        
                    messages.append(message)
                }
                
                completion(.success(messages))
                
            } catch {
                
                completion(.failure(FirebaseError.decodeMessageError))
            }
        }
        return listener
    }
    
    func updateMessageStatus(user: User, otherUser: User) {
        
        // for other user read
        let otherUserDoc = dataBase.collection(FirebaseCollection.chats.rawValue).document(otherUser.id)
            .collection(user.id).whereField("isRead", isEqualTo: MessageStatus.notRead.rawValue)
        
        otherUserDoc.getDocuments { snapshots, _ in
            
            snapshots?.documents.forEach({ document in
                
                document.reference.updateData([
                
                    "isRead": MessageStatus.isRead.rawValue
                    
                ])
            })
        }
        
        // for user self chatroom indicator badge
        let userDoc = dataBase.collection(FirebaseCollection.chats.rawValue).document(user.id)
            .collection(FirebaseCollection.recentMessages.rawValue).document(otherUser.id)
        
        userDoc.updateData([
            
            "isRead": MessageStatus.isRead.rawValue
        ])
    }
    
    func removeChat(userId: String, otherUserId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let batch = dataBase.batch()
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dispatchQueue = DispatchQueue.global()
        
        dispatchQueue.async { [weak self] in
            
            if let messageDoc = self?.dataBase.collection(FirebaseCollection.chats.rawValue).document(userId)
                .collection(otherUserId) {
                
                messageDoc.getDocuments { snapshots, _ in
                    
                    snapshots?.documents.forEach({ snapshot in
                        
                        batch.deleteDocument(snapshot.reference)
                        
                    })
                    semaphore.signal()
                }
            }
            semaphore.wait()
            
            if let recentDoc = self?.dataBase.collection(FirebaseCollection.chats.rawValue).document(userId)
                .collection(FirebaseCollection.recentMessages.rawValue).document(otherUserId) {
                
                batch.deleteDocument(recentDoc)
            }
            
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
