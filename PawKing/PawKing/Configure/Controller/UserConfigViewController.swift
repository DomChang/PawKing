//
//  UserConfigViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/18.
//

import UIKit
import FirebaseAuth
import SwiftUI

class UserConfigViewController: UIViewController {
    
    private let userManager = UserManager.shared
    
    private let lottie = LottieWrapper.shared
    
    private let tableView = UITableView()
    
    private let photoHelper = PKPhotoHelper()
    
    private var userId: String
    
    private var userName: String?
    
    private var userImageUrl: String?
    
//    private var userDescription: String?
    
    private var user: User? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var userImage: UIImage? {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(uid: String) {
        
        self.userId = uid
        
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
    
    func setup() {
        
        getUser()
        
        navigationItem.title = "User Configuration"
        
        tableView.dataSource = self
        
        tableView.delegate = self
        
        tableView.register(UserConfigCell.self, forCellReuseIdentifier: UserConfigCell.identifier)
        
        photoHelper.completionHandler = {[weak self] image in
            
            self?.userImage = image
        }
    }
    
    func style() {

        view.backgroundColor = .BattleGrey
        
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 20
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

    }
    
    func layout() {
        
        view.addSubview(tableView)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         leading: view.leadingAnchor,
                         bottom: view.bottomAnchor,
                         trailing: view.trailingAnchor)
    }
    
    func getUser() {
        
        guard let user = UserManager.shared.currentUser else { return }
        
        self.user = user
    }
    
    func showPetConfigVC(user: User) {
        
        let petConfigVC = PetConfigViewController(user: user,
                                                  editPet: nil,
                                                  isInitailSet: true,
                                                  isEdit: false)
        
        navigationController?.pushViewController(petConfigVC, animated: true)
        
    }
}

extension UserConfigViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserConfigCell.identifier,
                                                       for: indexPath) as? UserConfigCell
        else {
            
            fatalError("Cannot dequeue UserConfigCell")
        }
        
        if let userImage = userImage {
            
            cell.userImageView.image = userImage
        }
        
        if let user = user {
            
            cell.userNameTextfield.text = user.name
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        view.safeAreaLayoutGuide.layoutFrame.height
    }
}

extension UserConfigViewController: UserConfigCellDelegate {
    
    func didTapNext(from cell: UserConfigCell) {
        
        lottie.startLoading()
        
        guard let userName = cell.userNameTextfield.text,
              let image = cell.userImageView.image,
              var user = user
        else {
            lottie.stopLoading()
            lottie.showError(nil)
            return
        }
        
        user.name = userName
        user.description = cell.descriptionTextView.text
//        let user = User(id: userId,
//                        name: userName,
//                        petsId: [],
//                        currentPetId: "",
//                        userImage: "",
//                        description: ,
//                        friendPetsId: [],
//                        friends: [],
//                        recieveRequestsId: [],
//                        sendRequestsId: [])
        
        userManager.setupUser(user: user) { [weak self] result in
            
            switch result {
                
            case .success(let userId):
                
                self?.userId = userId
                
                // already update user data in uploadUserPhoto
                self?.userManager.uploadUserPhoto(userId: userId, image: image) { result in
                    
                    switch result {
                        
                    case .success:
                        
                        self?.lottie.stopLoading()
                        
                        self?.showPetConfigVC(user: user)
                        
                    case .failure(let error):
                        
                        self?.lottie.stopLoading()
                        self?.lottie.showError(error)
                    }
                }
            case .failure(let error):
                
                self?.lottie.stopLoading()
                self?.lottie.showError(error)
            }
        }
    }
    
    func didTapPhoto() {
        
        photoHelper.presentActionSheet(from: self)
    }
    
//    func textFieldDidChange(From textField: UITextField) {
//
//        if textField.text != "" && isPhotoExist {
//
//            userName = textField.text
//
//            confirmButtonEnable()
//
//            isNameExit = true
//
//        } else if textField.text != "" {
//
//            userName = textField.text
//
//            isNameExit = true
//
//        } else {
//
//            isNameExit = false
//
//            confirmButtonDisable()
//        }
//    }
}
