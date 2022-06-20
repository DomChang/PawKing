//
//  PetConfigViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/18.
//

import UIKit
import FirebaseFirestore

class PetConfigViewController: UIViewController {
    
    private let petManager = PetManager.shared
    
    private let userManager = UserManager.shared
    
    private let photoHelper = PKPhotoHelper()
    
    private var owner: User
    
    private let tableView = UITableView()
    
//    private let bottomLineView = UIView()
    
    private var petName: String?
    
    private var petImageUrl: String?
    
    private var petDescription: String?
    
    private var isInitailSet: Bool
    
    var petImage: UIImage? {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(user: User, isInitailSet: Bool) {
        self.owner = user
        self.isInitailSet = isInitailSet
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
        
        navigationItem.title = "寵物資料"
        
        if isInitailSet {
            
            navigationItem.hidesBackButton = true
        }
        
        tableView.dataSource = self
        
        tableView.delegate = self
        
        tableView.register(PetConfigCell.self, forCellReuseIdentifier: PetConfigCell.identifier)
        
        photoHelper.completionHandler = {[weak self] image in
            
            self?.petImage = image
        }
    }
    
    func style() {

        view.backgroundColor = .white
        
//        bottomLineView.backgroundColor = .O1
    }
    
    func layout() {
        
        view.addSubview(tableView)
//        view.addSubview(bottomLineView)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         leading: view.leadingAnchor,
                         bottom: view.safeAreaLayoutGuide.bottomAnchor,
                         trailing: view.trailingAnchor)
        
//        bottomLineView.anchor(top: tableView.bottomAnchor,
//                              centerX: view.centerXAnchor,
//                              width: view.frame.width,
//                              height: 1)
    }
}

extension PetConfigViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PetConfigCell.identifier,
                                                       for: indexPath) as? PetConfigCell
        else {
            
            fatalError("Cannot dequeue UserConfigCell")
        }
        
        if let userImage = petImage {
            
            cell.photoButton.setImage(userImage, for: .normal)
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        750
    }
}

extension PetConfigViewController: PetConfigCellDelegate {
    
    func didTapFinish(From cell: PetConfigCell) {
        
        guard let petName = cell.petNameTextfield.text,
              let petImage = cell.photoButton.image(for: .normal)
        else {
            return
        }
        
        let birthday = Timestamp(date: cell.birthdayPicker.date)

        var pet = Pet(id: "",
                      ownerId: owner.id,
                      name: petName,
                      gender: 0,
                      breed: "",
                      description: "",
                      birthday: birthday,
                      petImage: "",
                      postsId: [],
                      tracksId: [],
                      personality: PetPersonality(isChildFriendly: true,
                                                  isCatFriendly: true,
                                                  isDogFriendly: true))
        
        petManager.setupPet(userId: owner.id,
                            pet: &pet,
                            petName: petName,
                            petImage: petImage) { [weak self] result in
            
            switch result {
                
            case .success:
                
                self?.navigationController?.popToRootViewController(animated: true)
                
            case .failure(let error):
                
                print(error)
            }
        }
    }

    func didTapPhoto() {
        
        photoHelper.presentActionSheet(from: self)
    }
    
    func textFieldDidChange(From textField: UITextField) {
        
    }
}
