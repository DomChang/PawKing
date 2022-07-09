//
//  SettingViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/6.
//

import UIKit
import FirebaseAuth

class SettingViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private let userManager = UserManager.shared
    
    private let lottie = LottieWrapper.shared
    
    private let signOutActionController = UIAlertController(title: "Are you sure you want to sign out?",
                                                     message: nil,
                                                     preferredStyle: .actionSheet)
    
    private let deleteActionController = UIAlertController(title: "Are you sure you want to delete account?",
                                                     message: "All Data from your account will be delete",
                                                           preferredStyle: .alert)

    private let resignInActionController = UIAlertController(title: "You need to re-sign in to deleteaccount",
                                                             message: "All Data from your account will be delete",
                                                                   preferredStyle: .alert)
    
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
        
        setSignOutActionSheet()
        
        setDeleteActionSheet()
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
    
    private func signOut() {
        
        userManager.signOut { [weak self] result in
            
            switch result {
                
            case .success:
                
                self?.showSignInView()
                
            case .failure(let error):
                
                self?.lottie.showError(error)
            }
        }
    }
    
    private func setSignOutActionSheet() {
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        signOutActionController.addAction(cancelAction)
        
        let signOutAction  = UIAlertAction(title: "Confirm", style: .destructive) { [weak self] _ in
            
            self?.signOut()
        }
        signOutActionController.addAction(signOutAction)
    }
    
    private func setDeleteActionSheet() {
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        let deleteAction  = UIAlertAction(title: "Confirm", style: .destructive) { [weak self] _ in
            
            guard let user = self?.userManager.currentUser else { return }
            
            self?.userManager.deleteUser(userId: user.id) { result  in
                switch result {
                    
                case .success:
                    
                    self?.showSignInView()
                    
                case .failure(let error):
                    
                    guard let errorCode = AuthErrorCode.Code(rawValue: error._code) else { return }
                    
                    if errorCode == .requiresRecentLogin {
                        
                        guard let self = self else { return }
                        
                        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                            
                            self.signOut()
                        }
                        
                        self.resignInActionController.addAction(okAction)
                        
                        self.present(self.resignInActionController, animated: true)
                    }
                }
            }
        }
        deleteActionController.addAction(deleteAction)
        deleteActionController.addAction(cancelAction)
    }
    
    @objc private func dismissSignOutAlertController() {

        signOutActionController.dismiss(animated: true)
    }
    
    func showSignInView() {
        
        DispatchQueue.main.async {
            
           self.tabBarController?.selectedIndex = 0
            
            NotificationCenter.default.post(name: .resetTab, object: .none)
            
            NotificationCenter.default.post(name: .showSignInView, object: .none)
        }
    }
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
            
        case SettingSections.policy.rawValue:
            
            let policyVC = PrivacyViewController()
            
            present(policyVC, animated: true)
            
            return
            
        case SettingSections.blockedUser.rawValue:
            
            let blockVC = BlockViewController()
            
            navigationController?.pushViewController(blockVC, animated: true)
            
        case SettingSections.signOut.rawValue:
            
            present(signOutActionController, animated: true) {
                
                let tapGesture = UITapGestureRecognizer(
                    target: self,
                    action: #selector(self.dismissSignOutAlertController)
                )
                
                self.signOutActionController.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
            }
            
        case SettingSections.deleteAccount.rawValue:
            
            present(deleteActionController, animated: true)
            
        default:
            return
        }
    }
    
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
