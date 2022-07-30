//
//  UserListViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/17.
//

import UIKit

enum UserListType: String {
    
    case like = "Likes"
    
    case friend = "Friends"
    
    case blockedUser = "Blocked Users"
}

class UserListViewController: UIViewController {

    let tableView = UITableView(frame: .zero, style: .insetGrouped)

    var users: [User]? {
        
        didSet {
            
            DispatchQueue.main.async {
                
                if self.users?.count == 0 {
                    
                    self.emptyLabel.isHidden = false
                } else {
                    
                    self.emptyLabel.isHidden = true
                }
            }
        }
    }
    
    var usersId: [String]
    
    init(usersId: [String]) {

        self.usersId = usersId

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        style()
        layout()
    }
    
    private func setup() {
        
        tableView.register(UserListCell.self,
                           forCellReuseIdentifier: UserListCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        emptyLabel.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        
        getUsers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    private func style() {
        
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        view.backgroundColor = .BattleGrey
        
        tableView.backgroundColor = .BattleGreyUL
        tableView.layer.cornerRadius = 20
        
        emptyLabel.textColor = .BattleGreyLight
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
    }
    
    private func layout() {
        
        view.addSubview(tableView)
        tableView.addSubview(emptyLabel)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         leading: view.leadingAnchor,
                         bottom: view.bottomAnchor,
                         trailing: view.trailingAnchor)
        
        emptyLabel.anchor(centerY: tableView.centerYAnchor,
                           centerX: tableView.centerXAnchor)
    }
    
    func getUsers() {
        
        LottieWrapper.shared.startLoading()
        
        UserManager.shared.fetchUsers(userIds: usersId) { [weak self] result in
            
            switch result {
                
            case .success((let users, _)):
                
                self?.users = users
                
                LottieWrapper.shared.stopLoading()
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                
                LottieWrapper.shared.stopLoading()
                LottieWrapper.shared.showError(error: error)
            }
        }
    }
}

extension UserListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let users = users,
              let userSelf = UserManager.shared.currentUser else { return }
        
        guard users[indexPath.row].id != userSelf.id else { return }
        
        let userVC = UserPhotoWallViewController(otherUserId: users[indexPath.row].id)
        
        navigationController?.pushViewController(userVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserListCell.identifier,
                                                       for: indexPath) as? UserListCell else {
            fatalError("Cannot dequeue SearchResultCell")
        }
        
        if let users = users {
            
            cell.configureCell(user: users[indexPath.row])
        }
        
        return cell
    }
}
