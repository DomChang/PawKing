//
//  EditUserViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/20.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private let user: User
    
    private var userPets: [Pet]? {
        
        didSet {
            tableView.reloadSections(IndexSet(integer: 1), with: .fade)
        }
    }
    
    init(user: User) {
        
        self.user = user
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        style()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        
        getPets(by: user.id)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    func setup() {
        
        navigationItem.title = "Edit Profile"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(EditUserCell.self, forCellReuseIdentifier: EditUserCell.identifier)
        tableView.register(EditPetCell.self, forCellReuseIdentifier: EditPetCell.identifier)
    }
    
    func style() {

        view.backgroundColor = .BattleGrey
        
        tableView.layer.cornerRadius = 20
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        tableView.backgroundColor = .BattleGreyUL
        tableView.separatorStyle = .singleLine
    }
    
    func layout() {
        
        view.addSubview(tableView)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         leading: view.leadingAnchor,
                         bottom: view.bottomAnchor,
                         trailing: view.trailingAnchor)
    }
    
    func getPets(by userId: String) {
        
        PetManager.shared.fetchPets(userId: userId) { [weak self] result in
            
            switch result {
                
            case .success(let pets):
                
                self?.userPets = pets
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
}

extension EditProfileViewController: EditUserCellDelegate {
    
    func didEditUserName(to userName: String) {
        
        LottieWrapper.shared.startLoading()
        
        UserManager.shared.updateUserInfo(userId: user.id, userName: userName) { [weak self] result in
            
            switch result {
                
            case .success:
                
                LottieWrapper.shared.stopLoading()
                
                self?.navigationController?.popViewController(animated: true)
                
            case .failure(let error):
                
                LottieWrapper.shared.stopLoading()
                LottieWrapper.shared.showError(error: error)
            }
        }
    }
}

extension EditProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            guard let userPet = userPets?[indexPath.row] else { return }
            
            let petConfigVC = PetConfigViewController(user: user,
                                                      editPet: userPet,
                                                      isInitailSet: false,
                                                      isEdit: true)
            
            navigationController?.pushViewController(petConfigVC, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return 1
            
        } else {
            
            return userPets?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            guard let userCell = tableView.dequeueReusableCell(
                withIdentifier: EditUserCell.identifier,
                for: indexPath)
                    as? EditUserCell
            else {
                fatalError("Cannot dequeue EditUserCell")
            }
            
            userCell.configureCell(user: user)
            
            userCell.delegate = self
            
            return userCell
            
        } else {
            
            guard let petCell = tableView.dequeueReusableCell(withIdentifier: EditPetCell.identifier,
                                                               for: indexPath) as? EditPetCell,
                    let userPet = userPets?[indexPath.row]
            else {
                fatalError("Cannot dequeue EditUserCell")
            }
            
            petCell.configureCell(pet: userPet)
            
            return petCell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            
            return "Username Configuration"
        } else {
            
            return "Pets Configuration"
        }
    }
}
