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
    
    private var chatRoooms: [Conversation]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        style()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let user = UserManager.shared.currentUser {
            
            self.user = user
            
            getChatRooms(without: user.blockUsersId)
        }
    }
    
    private func setup() {
        
        navigationItem.title = "Chatroom"
        
        tableView.separatorStyle = .none
        
        view.backgroundColor = .BattleGrey
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatRoomCell.self, forCellReuseIdentifier: ChatRoomCell.identifier)
    }
    
    private func style() {
        
        tableView.layer.cornerRadius = 20
        
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func layout() {
        
        view.addSubview(tableView)
        
        tableView.fillSafeLayout()
    }
    
    func getChatRooms(without blockIds: [String]) {
        
        guard let user = user else {
            return
        }
        
        chatManager.fetchChatRooms(userId: user.id, blockIds: blockIds) { [weak self] result in
            
            switch result {
                
            case .success(let chatRooms):
                
                self?.chatRoooms = chatRooms
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
}

extension ChatRoomViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let user = user,
              let otherUser = chatRoooms?[indexPath.row].otherUser else { return }
        
        let messageVC = MessageViewController(user: user, otherUser: otherUser)
        
        navigationController?.pushViewController(messageVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatRoooms?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatRoomCell.identifier,
                                                       for: indexPath) as? ChatRoomCell
        else {
            fatalError("Cannot dequeue ChatRoomCell")
        }
        
        guard let chatRoom = chatRoooms?[indexPath.row] else { return cell}
        
        cell.configureCell(user: chatRoom.otherUser, recentMessage: chatRoom.message)
        
        return cell
    }
}
