//
//  SearchViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/23.
//

import UIKit
import FirebaseAuth

protocol ResultViewControllerDelegate {
    
    func didSelectResultUser(theOtherUser: User)
}

class ResultViewController: UISearchController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    var resultVCDelegate: ResultViewControllerDelegate?
    
    private let userManager = UserManager.shared
//    
//    var user: User
    
    var allUsers: [User]?
    
    var resultUsers: [User]? {
        didSet {
            tableView.reloadData()
        }
    }
    
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
        
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.identifier)
    }
    
    private func style() {
        
        navigationController?.navigationBar.tintColor = .white
        
        view.backgroundColor = .BattleGrey
        
        tableView.backgroundColor = .LightGray
        tableView.layer.cornerRadius = 20
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func layout() {
        
        view.addSubview(tableView)
        
        tableView.fillSafeLayout()
    }
    
    private func getAllUser() {
        
        userManager.fetchAllUser { [weak self] result in
            
            switch result {
                
            case .success(let allUsers):
                
                self?.allUsers = allUsers.filter({ $0.id != "unKnown" })
                
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
              
            let resultUsers = allUsers.filter({ $0.name.lowercased().hasPrefix(searchText.lowercased()) })
            
            self.resultUsers = resultUsers
            
            if let user = UserManager.shared.currentUser {
                self.resultUsers = self.resultUsers?.filter { $0.id != user.id }
            }
        }
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.identifier,
                                                       for: indexPath) as? SearchResultCell else {
            fatalError("Cannot dequeue SearchResultCell")
        }
        
        if let resultUsers = resultUsers {
            
            cell.configureCell(user: resultUsers[indexPath.row])
        }
        
        return cell
    }
}
