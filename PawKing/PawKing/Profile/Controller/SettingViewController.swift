//
//  SettingViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/6.
//

import UIKit

class SettingViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        style()
        layout()
    }
    
    private func setup() {
        
        tableView.register(SettingCell.self,
                           forCellReuseIdentifier: SettingCell.identifier)
        
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
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        SettingSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case SettingSections.policy.rawValue:
            
            guard let policyCell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier,
                                                                 for: indexPath) as? SettingCell
            else {
                fatalError("Cannot dequeue SettingCell")
            }
                
            policyCell.configureCell(image: UIImage.asset(.Icons_60px_Policy)!,
                                     title: "Privacy Policy",
                                     highlight: false)
            
            return policyCell
            
        case SettingSections.blockedUser.rawValue:
            
            guard let blockCell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier,
                                                                 for: indexPath) as? SettingCell
            else {
                fatalError("Cannot dequeue SettingCell")
            }
            
            blockCell.configureCell(image: UIImage.asset(.Icons_60px_Block)!,
                                    title: "Blocked Users",
                                    highlight: false)
            
            return blockCell
            
        case SettingSections.signOut.rawValue:
            
            guard let signOutCell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier,
                                                                 for: indexPath) as? SettingCell
            else {
                fatalError("Cannot dequeue SettingCell")
            }
            
            signOutCell.configureCell(image: UIImage.asset(.Icons_60px_SignOut)!,
                                      title: "Sign Out",
                                      highlight: true)
            
            return signOutCell
            
        case SettingSections.deleteAccount.rawValue:
            
            guard let deleteCell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier,
                                                                 for: indexPath) as? SettingCell
            else {
                fatalError("Cannot dequeue SettingCell")
            }
            
            deleteCell.configureCell(image: UIImage.asset(.Icons_60px_DeleteAccount)!,
                                     title: "Delete Acount",
                                     highlight: true)
            
            return deleteCell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}
