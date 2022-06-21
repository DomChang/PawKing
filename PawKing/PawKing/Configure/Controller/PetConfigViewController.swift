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
    
    private let bottomLineView = UIView()
    
    private var petName: String?
    
    private var petImageUrl: String?
    
    private var petDescription: String?
    
    var petImage: UIImage? {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(user: User) {
        self.owner = user
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
        
        navigationItem.hidesBackButton = true
        
        tableView.dataSource = self
        
        tableView.delegate = self
        
        tableView.register(PetConfigCell.self, forCellReuseIdentifier: PetConfigCell.identifier)
        
        photoHelper.completionHandler = {[weak self] image in
            
            self?.petImage = image
        }
    }
    
    func style() {

        view.backgroundColor = .white
        
        bottomLineView.backgroundColor = .O1
    }
    
    func layout() {
        
        view.addSubview(tableView)
        view.addSubview(bottomLineView)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         leading: view.leadingAnchor,
                         bottom: view.bottomAnchor,
                         trailing: view.trailingAnchor,
                         padding: UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0))
        
        bottomLineView.anchor(top: tableView.bottomAnchor,
                              centerX: view.centerXAnchor,
                              width: view.frame.width,
                              height: 1)
    }
    
    @objc func didTapFinish() {
        
    }
}

extension PetConfigViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PetConfigCell.identifier) as? PetConfigCell
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
        1000
    }
}

extension PetConfigViewController: PetConfigCellDelegate {
    
    func didTapFinish(From cell: PetConfigCell) {
        
        guard let petName = cell.petNameTextfield.text,
              let image = cell.photoButton.image(for: .normal)
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
        
        petManager.setupPet(pet: &pet) { [weak self] result in
            
            switch result {
                
            case .success(let petId):
                
//                self?.userId = petId
                
                self?.petManager.uploadPetPhoto(petId: petId, image: image) { result in
                    
                    switch result {
                        
                    case .success(let imageUrl):
                        
                        let imageUrlString = String(describing: imageUrl)
                        
                        pet.petImage = imageUrlString
                        
                        self?.petManager.updatePetInfo(pet: pet) { result in
                            
                            switch result {
                                
                            case .success:
                                
                                print("===Create pet success")
                                
                            case .failure(let error):
                                
                                print(error)
                            }
                        }
                        
                        guard let userId = self?.owner.id else {
                            
                            print("User id not found")
                            
                            return
                        }
                        
                        let userLocation = UserLocation(userId: userId,
                                                        userName: "",
                                                        userPhoto: "",
                                                        currentPetId: petId,
                                                        petName: petName,
                                                        petPhoto: imageUrlString,
                                                        location: GeoPoint(latitude: 0, longitude: 0),
                                                        status: 0)
                        
                        self?.userManager.updateUserLocation(location: userLocation, completion: { result in
                            switch result {
                                
                            case .success:
                                
                                print("===initial userLocation success")
                                self?.navigationController?.popToRootViewController(animated: true)
                                
                            case .failure(let error):
                                
                                print(error)
                            }
                        })
                        
                        self?.userManager.updateUserPet(userId: userId, petId: petId) { result in
                             
                            switch result {
                                
                            case .success:
                                
                                print("===Create pet success")
                                
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
    
    func textFieldDidChange(From textField: UITextField) {
        
    }
}
