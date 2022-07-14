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
    
    private let lottie = LottieWrapper.shared
    
    private let photoHelper = PKPhotoHelper()
    
    private var owner: User
    
    private var editPet: Pet?
    
    private let tableView = UITableView()
    
    private var petName: String?
    
    private var petImageUrl: String?
    
    private var isInitailSet: Bool
    
    private var isEdit: Bool
    
    private let deleteActionController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    
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
    
    private func setup() {
        
        if isEdit {
            
            navigationItem.title = "Pet Configuration"
        } else {
            
            navigationItem.title = "Add Pet"
        }
        
        if isInitailSet {
            
            navigationItem.hidesBackButton = true
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(
                systemName: "xmark",
                withConfiguration: UIImage.SymbolConfiguration(scale: .small)),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(didTapClose))
        } else if isEdit {
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "minus.circle.fill"),
                style: .plain,
                target: self,
                action: #selector(didTapAction))
            
            if let editPet = editPet {
                
                deleteActionController.title = "Are you sure you want to delete \(editPet.name)?"
                
                deleteActionController.message = "All Data according to \(editPet.name) will be delete"
                
                deleteActionController.view.tintColor = .BattleGrey
                
                setActionAlert(pet: editPet)
            }
        }
        
        tableView.dataSource = self
        
        tableView.delegate = self
        
        tableView.register(PetConfigCell.self, forCellReuseIdentifier: PetConfigCell.identifier)
        
        photoHelper.completionHandler = {[weak self] image in
            
            self?.petImage = image
        }
    }
    
    private func style() {
        
        navigationController?.navigationBar.tintColor = .white

        view.backgroundColor = .BattleGrey
        
        tableView.layer.cornerRadius = 20
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        tableView.separatorStyle = .none
    }
    
    private func layout() {
        
        view.addSubview(tableView)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         leading: view.leadingAnchor,
                         bottom: view.bottomAnchor,
                         trailing: view.trailingAnchor)
    }
    
    @objc private func didTapClose() {
        
        navigationController?.popViewController(animated: true)
        
        view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapAction() {
        
        present(deleteActionController, animated: true)
        
    }
    
    private func setActionAlert(pet: Pet) {
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        let deleteAction  = UIAlertAction(title: "Confirm", style: .destructive) { [weak self] _ in
            
            guard let self = self else { return }
            
            self.lottie.startLoading()
            
            self.petManager.deletePet(userId: self.owner.id, petId: pet.id) { result in
                
                switch result {
                    
                case .success:
                    
                    self.lottie.stopLoading()
                    self.navigationController?.popViewController(animated: true)
                    
                case .failure(let error):
                    
                    self.lottie.stopLoading()
                    self.lottie.showError(error: error)
                }
            }
        }
        deleteActionController.addAction(deleteAction)
        deleteActionController.addAction(cancelAction)
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
        
        lottie.startLoading()
        
        guard let petName = cell.petNameTextfield.text,
              let gender = cell.genderTextfield.text,
              let petImage = cell.petImageView.image,
              let birthday = cell.birthday
        else {
            
            lottie.stopLoading()
            lottie.showError(error: nil)
            
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
                    
                    self?.lottie.stopLoading()
                    
                    self?.navigationController?.popViewController(animated: true)
                    
                    NotificationCenter.default.post(name: .updateUser, object: .none)
                    
                case .failure(let error):
                    
                    cell.finishButtonEnable()
                    
                    self?.lottie.stopLoading()
                    self?.lottie.showError(error: error)
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
                    
                    self?.lottie.stopLoading()
                    
                    self?.navigationController?.popViewController(animated: true)
                    
                    self?.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    
                case .failure(let error):
                    
                    cell.finishButtonEnable()
                    
                    self?.lottie.stopLoading()
                    self?.lottie.showError(error: error)
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
