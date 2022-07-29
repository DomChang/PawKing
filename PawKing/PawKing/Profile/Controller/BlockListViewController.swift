//
//  BlockViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/6.
//

import UIKit

class BlockListViewController: UserListViewController {
    
    private var user = UserManager.shared.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = UserListType.blockedUser.rawValue

        emptyLabel.text = "No \(UserListType.blockedUser.rawValue)"
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            guard let user = user,
                  users != nil else { return }

            guard let blockId = users?[indexPath.row].id else { return }

            users?.remove(at: indexPath.row)

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
