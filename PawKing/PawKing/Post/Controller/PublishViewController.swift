//
//  PublishViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/14.
//

import UIKit
import FirebaseFirestore

final class PublishViewController: UIViewController {
    
    private let userManager = UserManager.shared
    
    private let postManager = PostManager.shared
    
    private var userPets: [Pet]?
    
    private var user: User
    
    private var selectedPet: Pet?
    
    let petImageView = UIImageView()
    
    let petNameLabel = UILabel()
    
    var photoImage = UIImage()
    
    let photoImageView = UIImageView()
    
    let captionTitleLabel = UILabel()
    
    let captionTextView = UITextView()
    
    let submitButton = UIButton()
    
    let selectedPetVImage = UIImageView()
    
    let closeButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        style()
        layout()
    }
    
    override func viewDidLayoutSubviews() {
        
        petImageView.makeRound()
    }
    
    init(user: User, image: UIImage) {
        
        self.user = user
        self.photoImage = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        
        getUserPet()
        
        submitButtonDisable()
        
        photoImageView.image = photoImage
        
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
    }
    
    func style() {
        
        view.backgroundColor = .white
        
        petImageView.clipsToBounds = true
        
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.layer.cornerRadius = 20
        photoImageView.clipsToBounds = true
        
        petNameLabel.textColor = .brown
        petNameLabel.font = UIFont.systemFont(ofSize: 30)
        
        captionTitleLabel.text = "相片說明"
        captionTitleLabel.font = UIFont.systemFont(ofSize: 16)
        
        captionTextView.layer.borderWidth = 1
        captionTextView.layer.borderColor = UIColor.Gray?.cgColor
        captionTextView.layer.cornerRadius = 20
        
        captionTextView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        submitButton.setTitle("Submit", for: .normal)
        submitButton.backgroundColor = .O1
        submitButton.layer.cornerRadius = 20
    }
    
    func layout() {
        
        view.addSubview(petImageView)
        view.addSubview(petNameLabel)
        view.addSubview(photoImageView)
        view.addSubview(captionTextView)
        view.addSubview(captionTitleLabel)
        view.addSubview(submitButton)
        
        petImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                            leading: view.leadingAnchor,
                            width: 60,
                            height: 60,
                            padding: UIEdgeInsets(top: 20, left: 30, bottom: 0, right: 0))
        
        petNameLabel.anchor(leading: petImageView.trailingAnchor,
                            trailing: view.trailingAnchor,
                            centerY: petImageView.centerYAnchor,
                            height: 25,
                            padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 16))
        
        photoImageView.anchor(top: petImageView.bottomAnchor,
                              centerX: view.centerXAnchor,
                              width: 200,
                              height: 200,
                              padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        
        captionTitleLabel.anchor(top: photoImageView.bottomAnchor,
                                 leading: captionTextView.leadingAnchor,
                                 trailing: view.trailingAnchor,
                                 height: 20,
                                 padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0))
        
        captionTextView.anchor(top: captionTitleLabel.bottomAnchor,
                               centerX: view.centerXAnchor,
                               width: 330,
                               height: 160,
                               padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
        
        submitButton.anchor(top: captionTextView.bottomAnchor,
                            leading: captionTextView.leadingAnchor,
                            trailing: captionTextView.trailingAnchor,
                            height: 50,
                            padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
    }
    
    func getUserPet() {
        
        userManager.fetchUserInfo(userId: user.id) { [weak self] result in
            
            switch result {
                
            case .success(let user):
                
                self?.user = user
                
                self?.userManager.fetchPets(userId: user.id) { result in
                    
                    switch result {
                        
                    case .success(let pets):
                        
                        self?.userPets = pets
                        
                        self?.getUserCurrentPet()
                        
                        self?.submitButtonEnable()
                        
                    case .failure(let error):
                        
                        print(error)
                    }
                }
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func getUserCurrentPet() {
        
        guard let userPets = userPets else {
            return
        }
        
        for userPet in userPets where userPet.id == user.currentPetId {
            
            selectedPet = userPet

            let imageUrl = URL(string: userPet.petImage)
            
            petImageView.kf.setImage(with: imageUrl)
            
            petNameLabel.text = userPet.name
        }
    }
    
    @objc func didTapSubmit() {
        
        submitButtonDisable()
        
        guard let selectedPet = selectedPet
        else {
            return
        }

        var post = Post(id: "",
                        userId: user.id,
                        petId: user.currentPetId,
                        photo: "",
                        caption: captionTextView.text,
                        likesId: [],
                        commentsId: [],
                        createdTime: Timestamp(date: Date()))
        
        postManager.setupPost(userId: user.id,
                              petId: selectedPet.id,
                              post: &post,
                              postImage: photoImage) { result in
            switch result {
                
            case .success:
                
                print("Create Post success")
                
                self.dismiss(animated: true)
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func submitButtonEnable() {
        
        submitButton.isEnabled = true
        
        submitButton.backgroundColor = .O1
    }
    
    func submitButtonDisable() {
        
        submitButton.isEnabled = false
        
        submitButton.backgroundColor = .Gray
    }
}
