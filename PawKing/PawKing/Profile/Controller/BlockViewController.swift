//
//  BlockViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/6.
//

import UIKit

class BlockViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private let userManager = UserManager.shared
    
    private var user = UserManager.shared.currentUser
    
    private let lottie = LottieWrapper.shared
    
    private var blockedUsers: [User]? {
        
        didSet {
            
            DispatchQueue.main.async {
                
                if self.blockedUsers?.count == 0 {
                    
                    self.noBlockUserLabel.isHidden = false
                } else {
                    
                    self.noBlockUserLabel.isHidden = true
                }
            }
        }
    }
    
    private let noBlockUserLabel = UILabel()

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
        
        noBlockUserLabel.text = "No Blocked User"
        noBlockUserLabel.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        
        fetchBlockedUsers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    private func style() {
        
        navigationItem.title = "Block Users"
        
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        view.backgroundColor = .BattleGrey
        
        tableView.backgroundColor = .BattleGreyUL
        tableView.layer.cornerRadius = 20
        
        noBlockUserLabel.textColor = .BattleGreyLight
        noBlockUserLabel.textAlignment = .center
        noBlockUserLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
    }
    
    private func layout() {
        
        view.addSubview(tableView)
        tableView.addSubview(noBlockUserLabel)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         leading: view.leadingAnchor,
                         bottom: view.bottomAnchor,
                         trailing: view.trailingAnchor)
        
        noBlockUserLabel.anchor(centerY: tableView.centerYAnchor,
                           centerX: tableView.centerXAnchor)
    }
    
    private func fetchBlockedUsers() {
        
        guard let user = user else {
            
            lottie.stopLoading()
            return
        }
        
        lottie.startLoading()
        
        userManager.fetchUsers(userIds: user.blockUsersId) { [weak self] result in
            
            switch result {
                
            case .success((let blockedUsers, _)):
                
                self?.lottie.stopLoading()
                self?.blockedUsers = blockedUsers
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                
                self?.lottie.stopLoading()
                self?.lottie.showError(error: error)
            }
        }
    }
}

extension BlockViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        blockedUsers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.identifier,
                                                       for: indexPath) as? SearchResultCell else {
            fatalError("Cannot dequeue SearchResultCell")
        }
        
        if let blockedUsers = blockedUsers {
            
            cell.configureCell(user: blockedUsers[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            guard let user = user,
                    blockedUsers != nil else { return }
            
            guard let blockId = blockedUsers?[indexPath.row].id else { return }

            blockedUsers?.remove(at: indexPath.row)
            
            userManager.removeBlockUser(userId: user.id, blockId: blockId) { [weak self] result in
                
                switch result {
                    
                case .success:
                    
                    print("remove block user success")
                    
                case .failure:
                    
                    self?.lottie.showError(error: nil)
                }
            }

            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
