//
//  FriendRequestViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/30.
//

import UIKit

class FriendRequestViewController: UIViewController {

    private let tableView = UITableView()

    private let userManager = UserManager.shared

    private var user = UserManager.shared.currentUser

    private var senders: [User] = [] {
        
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
            }
        }
    }

//    init(user: User) {
//
//        self.user = user
//
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        updateUser()
        
        setup()
        style()
        layout()
    }

    private func setup() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateUser),
                                               name: .updateUser,
                                               object: nil)
        
        navigationItem.title = "Connect Requests"
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.topItem?.backButtonTitle = ""

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(FriendRequestCell.self, forCellReuseIdentifier: FriendRequestCell.identifier)
    }

    private func style() {
        
        view.backgroundColor = .BattleGrey
        
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 20
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    private func layout() {

        view.addSubview(tableView)

        tableView.fillSafeLayout()
    }
    
    @objc private func updateUser() {
        
//        userManager.listenUserInfo(userId: user.id) { [weak self] result in
//
//            switch result {
//
//            case .success(let user):
                
                user = UserManager.shared.currentUser
                
                getSenderInfo()
                
//            case .failure(let error):
//
//                print(error)
//            }
//        }
    }
    
    private func getSenderInfo() {
        
        guard let user = user else { return }
        
        userManager.fetchUsers(userIds: user.recieveRequestsId) { [weak self] result in
            
            switch result {
                
            case .success(let senders):
                
                self?.senders = senders
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
}

extension FriendRequestViewController: FriendRequestCellDelegate {
    
    func didTapAccept(from cell: FriendRequestCell) {
        
        guard let user = user,
              let sender = cell.sender else { return }
                
        userManager.acceptFriendRequest(senderId: sender.id,
                                        userId: user.id) { result in
            switch result {
                
            case.success:
                
                print("Accept Friend request")
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func didTapDeny(from cell: FriendRequestCell) {
        
        guard let user = user,
              let sender = cell.sender else { return }
        
        userManager.denyFriendRequest(senderId: sender.id, userId: user.id) { result in
            
            switch result {
                
            case .success:
                
                print("Deny Friend request")
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
}

extension FriendRequestViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        senders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: FriendRequestCell.identifier,
                                                       for: indexPath) as? FriendRequestCell else {
            fatalError("Cannot dequeue SearchResultCell")
        }
        
        cell.delegate = self
        
        cell.configureCell(sender: senders[indexPath.row])

        return cell
    }
}
