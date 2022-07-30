//
//  SearchViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/23.
//

import UIKit
import FirebaseAuth

protocol ResultViewControllerDelegate: AnyObject {
    
    func didSelectResultUser(theOtherUser: User)
}

class ResultViewController: UISearchController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    var resultVCDelegate: ResultViewControllerDelegate?
    
    var allUsers: [User]?
    
    var resultUsers: [User]? {
        didSet {
            tableView.reloadData()
            
            if resultUsers?.count == 0 {
                
                emptyLabel.isHidden = false
            } else {
                
                emptyLabel.isHidden = true
            }
        }
    }
    
    private let emptyLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        definesPresentationContext = true

        view.backgroundColor = .white
        
        setup()
        style()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        navigationController?.navigationBar.isHidden = false
    }
    
    private func setup() {
        
        getAllUser()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.allowsSelection = true
        
        tableView.register(UserListCell.self, forCellReuseIdentifier: UserListCell.identifier)
        
        emptyLabel.text = "No Result"
        emptyLabel.isHidden = true
    }
    
    private func style() {
        
        navigationController?.navigationBar.tintColor = .white
        
        view.backgroundColor = .BattleGrey
        
        tableView.backgroundColor = .BattleGreyUL
        tableView.layer.cornerRadius = 20
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        emptyLabel.textColor = .BattleGreyLight
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
    }
    
    private func layout() {
        
        view.addSubview(tableView)
        tableView.addSubview(emptyLabel)
        
        tableView.fillSafeLayout()
        
        emptyLabel.anchor(bottom: tableView.centerYAnchor,
                          centerX: tableView.centerXAnchor,
                          padding: UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0))
    }
    
    private func getAllUser() {
        
        UserManager.shared.fetchAllUser { [weak self] result in
            
            switch result {
                
            case .success(let allUsers):
                
                self?.allUsers = allUsers.filter({ $0.id != UserStatus.unknown.rawValue })
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
}

extension ResultViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        searchController.searchBar.searchTextField.textColor = .white
        
        if let allUsers = allUsers,
           let searchText = searchController.searchBar.text {
            
            self.resultUsers = filterUsersWithPrefixText(users: allUsers, text: searchText)
            
            if let user = UserManager.shared.currentUser {
                self.resultUsers = self.resultUsers?.filter { $0.id != user.id }
            }
        }
    }
    
    func filterUsersWithPrefixText(users: [User], text: String) -> [User] {
        
        let resultUsers = users.filter({ $0.name.lowercased().hasPrefix(text.lowercased()) })
        
        return resultUsers
    }
}

extension ResultViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard Auth.auth().currentUser != nil else {
            
            NotificationCenter.default.post(name: .showSignInView, object: .none)
            return
        }
        
        if let resultUsers = resultUsers {
            
            self.resultVCDelegate?.didSelectResultUser(theOtherUser: resultUsers[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        resultUsers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserListCell.identifier,
                                                       for: indexPath) as? UserListCell else {
            fatalError("Cannot dequeue SearchResultCell")
        }
        
        if let resultUsers = resultUsers {
            
            cell.configureCell(user: resultUsers[indexPath.row])
        }
        
        return cell
    }
}
