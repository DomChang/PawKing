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
    
    private var editPet: Pet?
    
    private let tableView = UITableView()
    
    private var petName: String?
    
    private var petImageUrl: String?
    
    private var isInitailSet: Bool
    
    private var isEdit: Bool
    
    var petImage: UIImage? {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(user: User, editPet: Pet?, isInitailSet: Bool, isEdit: Bool) {
        self.owner = user
        self.isInitailSet = isInitailSet
        self.isEdit = isEdit
        
        if let editPet = editPet {
            self.editPet = editPet
        }
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
        
        if isEdit {
            
            navigationItem.title = "Pet Configuration"
        } else {
            
            navigationItem.title = "Add Pet"
        }
        
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
        
        tableView.separatorStyle = .none
    }
    
    func layout() {
        
        view.addSubview(tableView)
        
        tableView.fillSafeLayout()
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
        
        if isEdit,
            let editPet = editPet {
            
            cell.configureCell(pet: editPet)
        }
        
        if let petImage = petImage {
            
            cell.petImageView.image = petImage
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
              let gender = cell.genderTextfield.text,
              let petImage = cell.petImageView.image,
              let birthday = cell.birthday
        else {
            return
        }
        
        if isEdit {
            
            guard let editPet = editPet else { return }
            
            petManager.updatePetInfo(userId: owner.id,
                                     petId: editPet.id,
                                     image: petImage,
                                     name: petName,
                                     gender: gender,
                                     birthday: birthday) { [weak self] result in
                switch result {
                    
                case .success:
                    
                    cell.finishButtonEnable()
                    
                    self?.navigationController?.popViewController(animated: true)
                    
                case .failure(let error):
                    
                    cell.finishButtonEnable()
                    
                    print(error)
                }
            }
            
        } else {
            
//            guard let petName = cell.petNameTextfield.text,
//                  let gender = cell.genderTextfield.text,
//                  let petImage = cell.petImageView.image
//            else {
//                return
//            }
//
//            let birthday = Timestamp(date: cell.birthdayPicker.date)

            var pet = Pet(id: "",
                          ownerId: owner.id,
                          name: petName,
                          gender: gender,
                          breed: "",
                          description: "",
                          birthday: birthday,
                          createdTime: Timestamp(date: Date()),
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
                    
                    cell.finishButtonEnable()
                    
                    self?.navigationController?.popViewController(animated: true)
                    
                    self?.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    
                case .failure(let error):
                    
                    cell.finishButtonEnable()
                    
                    print(error)
                }
            }
        }
    }

    func didTapPhoto() {
        
        photoHelper.presentActionSheet(from: self)
    }
    
    func textFieldDidChange(From textField: UITextField) {
        
    }
}
