//
//  ChatViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/14.
//

import UIKit

class ChatRoomViewController: UIViewController {
    
    private let user: User
    
    private let tableView = UITableView()
    
    private let chatManager = ChatManager.shared
    
    private var chatRoooms: [Conversation]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        style()
        layout()
    }
    
    private func setup() {
        
        view.backgroundColor = .white
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatRoomCell.self, forCellReuseIdentifier: ChatRoomCell.identifier)
    }
    
    private func style() {
        
    }
    
    private func layout() {
        
        view.addSubview(tableView)
        
        tableView.fillSafeLayout()
    }
    
    func getChatRooms() {
        
        chatManager.fetchChatRooms(userId: user.id) { [weak self] result in
            
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
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatRoooms?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatRoomCell.identifier, for: indexPath) as? ChatRoomCell
        else {
            fatalError("Cannot dequeue ChatRoomCell")
        }
        
        guard let chatRoom = chatRoooms?[indexPath.row] else { return cell}
        
        cell.configureCell(user: chatRoom.user, recentMessage: chatRoom.message)
        
        return cell
    }
}
