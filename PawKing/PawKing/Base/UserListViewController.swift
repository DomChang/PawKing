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
}

class UserListViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private let userManager = UserManager.shared
    
    private let postManager = PostManager.shared
    
    private let lottie = LottieWrapper.shared
    
    private var users: [User]? {
        
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
    
    private var usersId: [String]
    
    private var listType: UserListType
    
    private var postId: String?
    
    init(usersId: [String], listType: UserListType, postId: String?) {
        
        self.usersId = usersId
        self.listType = listType
        self.postId = postId
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        style()
        layout()
    }
    
    private func setup() {
        
        tableView.register(SearchResultCell.self,
                           forCellReuseIdentifier: SearchResultCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        emptyLabel.text = "No \(listType.rawValue)"
        emptyLabel.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        
        fetchUsers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    private func style() {
        
        navigationItem.title = listType.rawValue
        
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
    
    private func fetchUsers() {
        
        lottie.startLoading()
        
        userManager.fetchUsers(userIds: usersId) { [weak self] result in
            
            switch result {
                
            case .success((let users,
                           let deletedUsersId)):
                
                self?.users = users
                
                self?.lottie.stopLoading()
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
                if self?.listType == UserListType.like {
                    
                    deletedUsersId.forEach({
                            
                        guard let postId = self?.postId else {
                            return
                        }

                        self?.postManager.removePostLike(postId: postId,
                                                         userId: $0)
                    })
                }
                
            case .failure(let error):
                
                self?.lottie.stopLoading()
                self?.lottie.showError(error: error)
            }
        }
    }
}

extension UserListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let users = users,
              let userSelf = userManager.currentUser else { return }
        
        guard users[indexPath.row].id != userSelf.id else { return }
        
        let userVC = UserPhotoWallViewController(otherUserId: users[indexPath.row].id)
        
        navigationController?.pushViewController(userVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.identifier,
                                                       for: indexPath) as? SearchResultCell else {
            fatalError("Cannot dequeue SearchResultCell")
        }
        
        if let users = users {
            
            cell.configureCell(user: users[indexPath.row])
        }
        
        return cell
    }
}
