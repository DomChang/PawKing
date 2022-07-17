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
                
                if self.senders.isEmpty {
                    
                    self.noRequestLabel.isHidden = false
                } else {
                    
                    self.noRequestLabel.isHidden = true
                }
            }
        }
    }
    
    private let noRequestLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        updateUser()
        
        setup()
        style()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
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
        
        noRequestLabel.text = "No Request"
        noRequestLabel.isHidden = true
    }

    private func style() {
        
        view.backgroundColor = .BattleGrey
        
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 20
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        noRequestLabel.textColor = .BattleGreyLight
        noRequestLabel.textAlignment = .center
        noRequestLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
    }

    private func layout() {

        view.addSubview(tableView)
        tableView.addSubview(noRequestLabel)

        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         leading: view.leadingAnchor,
                         bottom: view.bottomAnchor,
                         trailing: view.trailingAnchor)
        
        noRequestLabel.anchor(centerY: tableView.centerYAnchor,
                              centerX: tableView.centerXAnchor)
    }
    
    @objc private func updateUser() {
                
        user = UserManager.shared.currentUser
        
        getSenderInfo()
    }
    
    private func getSenderInfo() {
        
        guard let user = user else { return }
        
        userManager.fetchUsers(userIds: user.recieveRequestsId) { [weak self] result in
            
            switch result {
                
            case .success((let senders, _)):
                
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
