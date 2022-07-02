//
//  SearchViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/23.
//

import UIKit

class ResultViewController: UISearchController {
    
    private let tableView = UITableView()
    
    private let userManager = UserManager.shared
//    
//    var user: User
    
    var allUsers: [User]?
    
    var resultUsers: [User]? {
        didSet {
            tableView.reloadData()
        }
    }
    
//    init(user: User) {
//        
//        self.user = user
//        
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        setup()
        style()
        layout()
    }
    
    private func setup() {
        
        getAllUser()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.allowsSelection = true
        
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.identifier)
    }
    
    private func style() {
        
    }
    
    private func layout() {
        
        view.addSubview(tableView)
        
        tableView.fillSafeLayout()
    }
    
    private func getAllUser() {
        
        userManager.fetchAllUser { [weak self] result in
            
            switch result {
                
            case .success(let allUsers):
                
                self?.allUsers = allUsers
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
}

extension ResultViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let allUsers = allUsers,
           let searchText = searchController.searchBar.text {
              
            let resultUsers = allUsers.filter({ $0.name.lowercased().hasPrefix(searchText.lowercased()) })
            
            self.resultUsers = resultUsers
        }
    }
}

extension ResultViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let resultUsers = resultUsers {
            
            let userPhotoVC = UserPhotoWallViewController(otherUser: resultUsers[indexPath.row])
            
            let navUserPhotoVC = UINavigationController(rootViewController: userPhotoVC)
            
            navUserPhotoVC.modalPresentationStyle = .overFullScreen
            
            self.present(navUserPhotoVC, animated: true)
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
