//
//  UserConfigViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/18.
//

import UIKit

class UserConfigViewController: UIViewController {
    
    private let userManager = UserManager.shared
    
    private let tableView = UITableView()
    
    private let photoHelper = PKPhotoHelper()
    
    private var userId: String?
    
    private var userName: String?
    
    private var userImageUrl: String?
    
    private var userDescription: String?
    
    var userImage: UIImage? {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        style()
        layout()
    }
    
    func setup() {
        
        navigationItem.title = "使用者資料"
        
        tableView.dataSource = self
        
        tableView.delegate = self
        
        tableView.register(UserConfigCell.self, forCellReuseIdentifier: UserConfigCell.identifier)
        
        photoHelper.completionHandler = {[weak self] image in
            
            self?.userImage = image
        }
    }
    
    func style() {

        view.backgroundColor = .white
    }
    
    func layout() {
        
        view.addSubview(tableView)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         leading: view.leadingAnchor,
                         bottom: view.bottomAnchor,
                         trailing: view.trailingAnchor,
                         padding: UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0))
    }
    
    func showPetConfigVC(user: User) {
        
        let petConfigVC = PetConfigViewController(user: user)
        
        navigationController?.pushViewController(petConfigVC, animated: true)
        
    }
}

extension UserConfigViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserConfigCell.identifier) as? UserConfigCell
        else {
            
            fatalError("Cannot dequeue UserConfigCell")
        }
        
        if let userImage = userImage {
            
            cell.photoButton.setImage(userImage, for: .normal)
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
        
        guard let userName = cell.userNameTextfield.text,
              let image = cell.photoButton.image(for: .normal)
        else {
            return
        }

        var user = User(id: "",
                        name: userName,
                        petsId: [],
                        userImage: "",
                        description: cell.descriptionTextView.text,
                        friendPetsId: [],
                        friends: [],
                        recieveFriendRequest: [],
                        sendRequestsId: [])
        
        userManager.setupUser(user: &user) { [weak self] result in
            
            switch result {
                
            case .success(let userId):
                
                self?.userId = userId
                
                self?.userManager.uploadUserPhoto(userId: userId, image: image) { result in
                    
                    switch result {
                        
                    case .success(let imageUrl):
                        
                        let imageUrlString = String(describing: imageUrl)
                        
                        user.userImage = imageUrlString
                        
                        self?.userManager.updateUserInfo(user: user) { result in
                            
                            switch result {
                                
                            case .success:
                                
                                self?.showPetConfigVC(user: user)
                                
                            case .failure(let error):
                                
                                print(error)
                            }
                        }
                        
                    case .failure(let error):
                        
                        print(error)
                    }
                }
                
            case .failure(let error):
                
                print(error)
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
