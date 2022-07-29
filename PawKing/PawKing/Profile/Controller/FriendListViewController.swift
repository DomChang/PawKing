//
//  FriendListViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/24.
//

import UIKit

class FriendListViewController: UserListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = UserListType.friend.rawValue

        emptyLabel.text = "No \(UserListType.friend.rawValue)"
    }
}
