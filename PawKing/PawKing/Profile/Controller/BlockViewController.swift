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
    
    private var blockedUsers: [User]?

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        style()
        layout()
    }
    
    private func setup() {
        
        lottie.startLoading()
        
        fetchBlockedUsers()
        
        tableView.register(SearchResultCell.self,
                           forCellReuseIdentifier: SearchResultCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    private func style() {
        
        navigationItem.title = "Setting"
        
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        view.backgroundColor = .BattleGrey
        
        tableView.backgroundColor = .LightGray
        tableView.layer.cornerRadius = 20
    }
    
    private func layout() {
        
        view.addSubview(tableView)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         leading: view.leadingAnchor,
                         bottom: view.bottomAnchor,
                         trailing: view.trailingAnchor)
    }
    
    private func fetchBlockedUsers() {
        
        guard let user = user else {
            
            lottie.stopLoading()
            return
        }

        userManager.fetchUsers(userIds: user.blockUsersId) { [weak self] result in
            
            switch result {
                
            case .success(let blockedUsers):
                
                self?.lottie.stopLoading()
                self?.blockedUsers = blockedUsers
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                
                self?.lottie.stopLoading()
                self?.lottie.showError(error)
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
                    
                    self?.lottie.showError(nil)
                }
            }

            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
