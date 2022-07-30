//
//  LikeUserViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/24.
//

import UIKit

class LikeUserListViewController: UserListViewController {
    
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
        
        LottieWrapper.shared.startLoading()
        
        UserManager.shared.fetchUsers(userIds: usersId) { [weak self] result in
            
            switch result {
                
            case .success((let users,
                           let deletedUsersId)):
                
                self?.users = users
                
                LottieWrapper.shared.stopLoading()
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                    
                deletedUsersId.forEach({
                        
                    guard let postId = self?.postId else {
                        return
                    }

                    PostManager.shared.removePostLike(postId: postId,
                                                     userId: $0)
                })

            case .failure(let error):
                
                LottieWrapper.shared.stopLoading()
                LottieWrapper.shared.showError(error: error)
            }
        }

    }
}
