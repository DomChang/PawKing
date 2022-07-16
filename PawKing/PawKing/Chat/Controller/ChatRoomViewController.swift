//
//  ChatViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/14.
//

import UIKit

class ChatRoomViewController: UIViewController {
    
    private var user: User?
    
    private let tableView = UITableView()
    
    private let chatManager = ChatManager.shared
    
    private var chatRoooms: [Conversation] = [] {
        didSet {
            
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                
                if self.chatRoooms.isEmpty {
                    
                    self.noChatLabel.isHidden = false
                } else {
                    
                    self.noChatLabel.isHidden = true
                }
            }
        }
    }
    
    private let noChatLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarItem.setBadgeTextAttributes([.font: UIFont.systemFont(ofSize: 6), .foregroundColor: UIColor.red], for: .normal)
        tabBarItem.badgeValue = "⬤"
        tabBarItem.badgeColor = UIColor.clear
        
        setup()
        style()
        layout()
    }
    
    private func setup() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getChatRooms),
                                               name: .updateChatRooms,
                                               object: nil)
        
        getChatRooms()
        
        navigationItem.title = "Chatroom"
        
        tableView.separatorStyle = .none
        
        view.backgroundColor = .BattleGrey
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatRoomCell.self, forCellReuseIdentifier: ChatRoomCell.identifier)
        
        noChatLabel.text = "No Chat"
        noChatLabel.isHidden = true
    }
    
    private func style() {
        
        tableView.layer.cornerRadius = 20
        
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        noChatLabel.textColor = .BattleGreyLight
        noChatLabel.textAlignment = .center
        noChatLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
    }
    
    private func layout() {
        
        view.addSubview(tableView)
        tableView.addSubview(noChatLabel)
        
        tableView.fillSafeLayout()
        
        noChatLabel.anchor(centerY: tableView.centerYAnchor,
                           centerX: tableView.centerXAnchor)
    }
    
    @objc private func getChatRooms() {
        
        guard let user = UserManager.shared.currentUser else {
            return
        }

        self.user = user

//        chatManager.listenChatRooms(userId: user.id, blockIds: user.blockUsersId) { [weak self] result in
//
//            switch result {
//
//            case .success(let chatRooms):
//
//                self?.chatRoooms = chatRooms
//
//            case .failure(let error):
//
//                print(error)
//            }
//        }
        
        if let chatRooms = ChatManager.shared.chatRooms {
            chatRoooms = chatRooms
        }
    }
}

extension ChatRoomViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let user = user else { return }
        
        let otherUser = chatRoooms[indexPath.row].otherUser
        
        let otherUserId = chatRoooms[indexPath.row].message.otherUserId
        
        let messageVC = MessageViewController(user: user, otherUser: otherUser, otherUserId: otherUserId)
        
        navigationController?.pushViewController(messageVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatRoooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatRoomCell.identifier,
                                                       for: indexPath) as? ChatRoomCell
        else {
            fatalError("Cannot dequeue ChatRoomCell")
        }
        
        let chatRoom = chatRoooms[indexPath.row]
        
        cell.configureCell(user: chatRoom.otherUser, recentMessage: chatRoom.message)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            guard let user = user  else { return }
            
            let otherUserId = chatRoooms[indexPath.row].message.otherUserId

            chatRoooms.remove(at: indexPath.row)

            tableView.deleteRows(at: [indexPath], with: .fade)
            
            chatManager.removeChat(userId: user.id, otherUserId: otherUserId) { result in
                    
                switch result {
                    
                case .success:
                    
                    print("Chat deleted")
                    
                case .failure(let error):
                    
                    print(error)
                }
            }
        }
    }
}
