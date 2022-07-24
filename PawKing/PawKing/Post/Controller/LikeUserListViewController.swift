//
//  LikeUserViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/24.
//

import UIKit

class LikeUserListViewController: UserListViewController {
    
    private let postManager = PostManager.shared
    
    private var postId: String
    
    init(usersId: [String], postId: String) {
        self.postId = postId
        super.init(usersId: usersId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = UserListType.like.rawValue

        emptyLabel.text = "No \(UserListType.like.rawValue)"
    }
    
    override func getUsers() {
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
                    
                deletedUsersId.forEach({
                        
                    guard let postId = self?.postId else {
                        return
                    }

                    self?.postManager.removePostLike(postId: postId,
                                                     userId: $0)
                })

                
            case .failure(let error):
                
                self?.lottie.stopLoading()
                self?.lottie.showError(error: error)
            }
        }

    }
}
