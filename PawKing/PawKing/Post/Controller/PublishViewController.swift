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
    
    private var user: User?
    
    private var selectedPet: Pet?
    
    private let photoHelper = PKPhotoHelper()
    
    private let scrollView = UIScrollView()
    
    private let selectPetTitleLabel = UILabel()
    
    let petImageView = UIImageView()
    
    let petNameLabel = UILabel()
    
    private let selectPetButton = UIButton()
    
    var photoImage = UIImage()
    
    let photoImageView = UIImageView()
    
    let captionTitleLabel = UILabel()
    
    let captionTextView = InputTextView()
    
    let submitButton = UIButton()
    
    let selectedPetVImage = UIImageView()
    
    let closeButton = UIButton()
    
    init(image: UIImage) {
        
        self.photoImage = image
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
    
    override func viewDidLayoutSubviews() {
        
        petImageView.makeRound()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let user = UserManager.shared.currentUser {
            
            self.user = user
            
            getUserPet()
        }
    }

    func setup() {
        
        submitButtonDisable()
        
        scrollView.isScrollEnabled = true
        
        photoImageView.image = photoImage
        
        photoImageView.isUserInteractionEnabled = true
        
        photoImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapPhoto)))
        
        selectPetButton.addTarget(self, action: #selector(didTapPet), for: .touchUpInside)
        
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        
        photoHelper.completionHandler = { [weak self] image in
            
            self?.photoImage = image
            self?.photoImageView.image = image
        }
    }
    
    func style() {
        
        navigationItem.title = "New Post"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(
            systemName: "xmark",
            withConfiguration: UIImage.SymbolConfiguration(scale: .small)),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapClose))
        
        view.backgroundColor = .white
        
        petImageView.contentMode = .scaleAspectFill
        petImageView.clipsToBounds = true
        
        selectPetTitleLabel.text = "Post with"
        selectPetTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        selectPetTitleLabel.textColor = .BattleGrey
        
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        
        petNameLabel.textColor = .BattleGrey
        petNameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        captionTitleLabel.text = "Caption"
        captionTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        captionTitleLabel.textColor = .BattleGrey
        
        captionTextView.placeholder = "Write a caption..."
        captionTextView.isScrollEnabled = false
        captionTextView.font = UIFont.systemFont(ofSize: 16)
        
        submitButton.setTitle("Submit", for: .normal)
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        submitButton.backgroundColor = .Orange1
        submitButton.layer.cornerRadius = 4
    }
    
    func layout() {
        
        let backView = UIView()
        backView.layer.cornerRadius = 20
        backView.backgroundColor = .white
        
        let hStack = UIStackView(arrangedSubviews: [petImageView, petNameLabel])
        hStack.axis = .horizontal
        hStack.distribution = .fill
        hStack.spacing = 8
        
        selectPetTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        petImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        view.addSubview(scrollView)
        scrollView.addSubview(photoImageView)
        scrollView.addSubview(backView)
        scrollView.addSubview(selectPetTitleLabel)
        scrollView.addSubview(hStack)
        scrollView.addSubview(selectPetButton)
        scrollView.addSubview(captionTextView)
        scrollView.addSubview(captionTitleLabel)
        scrollView.addSubview(submitButton)
        
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                          leading: view.leadingAnchor,
                          bottom: view.bottomAnchor,
                          trailing: view.trailingAnchor)
        
        photoImageView.anchor(top: scrollView.topAnchor,
                              leading: scrollView.leadingAnchor,
                              trailing: scrollView.trailingAnchor,
                              width: view.frame.width,
                              height: view.frame.width + 20)
        photoImageView.widthAnchor.constraint(
            equalTo: scrollView.widthAnchor
        ).isActive = true
        
        backView.anchor(top: photoImageView.bottomAnchor,
                        leading: scrollView.leadingAnchor,
                        bottom: view.bottomAnchor,
                        trailing: scrollView.trailingAnchor,
                        padding: UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0))
        
        selectPetTitleLabel.anchor(leading: scrollView.leadingAnchor,
                                   centerY: hStack.centerYAnchor,
                                   padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0))
        
        petImageView.constrainWidth(constant: 40)
        
        hStack.anchor(top: backView.topAnchor,
                      leading: selectPetTitleLabel.trailingAnchor,
                      trailing: scrollView.trailingAnchor,
                      height: 40,
                      padding: UIEdgeInsets(top: 20, left: 30, bottom: 0, right: 20))
        
        selectPetButton.anchor(top: hStack.topAnchor,
                               leading: selectPetTitleLabel.leadingAnchor,
                               bottom: hStack.bottomAnchor,
                               trailing: hStack.trailingAnchor)
        
        captionTitleLabel.anchor(top: hStack.bottomAnchor,
                                 leading: scrollView.leadingAnchor,
                                 trailing: scrollView.trailingAnchor,
                                 padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
        
        captionTextView.anchor(top: captionTitleLabel.bottomAnchor,
                               leading: scrollView.leadingAnchor,
                               trailing: scrollView.trailingAnchor,
                               padding: UIEdgeInsets(top: 8, left: 20, bottom: 0, right: 20))
        
        submitButton.anchor(top: captionTextView.bottomAnchor,
                            leading: captionTextView.leadingAnchor,
                            bottom: scrollView.bottomAnchor,
                            trailing: captionTextView.trailingAnchor,
                            height: 40,
                            padding: UIEdgeInsets(top: 20, left: 0, bottom: 50, right: 0))
        
        // Change top bounce area backgroud color
        scrollView.layoutIfNeeded()
        let topView = UIView(frame: CGRect(x: 0, y: -scrollView.bounds.height,
                width: scrollView.bounds.width, height: scrollView.bounds.height))
        topView.backgroundColor = .BattleGrey
        scrollView.addSubview(topView)
    }
    
    func getUserPet() {
        
        guard let user = user else {
            return
        }
        
        userManager.fetchUserInfo(userId: user.id) { [weak self] result in
            
            switch result {
                
            case .success(let user):
                
                self?.user = user
                
                self?.userManager.fetchPets(userId: user.id) { result in
                    
                    switch result {
                        
                    case .success(let pets):
                        
                        self?.userPets = pets
                        
                        self?.getUserCurrentPet(user: user)
                        
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
    
    func getUserCurrentPet(user: User) {
        
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
        
        guard let user = user,
                let selectedPet = selectedPet
        else {
            return
        }

        var post = Post(id: "",
                        userId: user.id,
                        petId: selectedPet.id,
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
    
    @objc func didTapPhoto() {
        
        photoHelper.presentActionSheet(from: self)
    }
    
    @objc func didTapPet() {
        
        guard let userPets = userPets else {
            return
        }
        
        let choosePetVC = ChoosePetViewController(pets: userPets, isPost: true)
        
        choosePetVC.delegate = self
        
        let navChoosePetVC = UINavigationController(rootViewController: choosePetVC)

        if let sheet = navChoosePetVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.preferredCornerRadius = 20
        }
        
        present(navChoosePetVC, animated: true, completion: nil)
        
    }
    
    @objc func didTapClose() {
        
        dismiss(animated: true)
    }
    
    func submitButtonEnable() {
        
        submitButton.isEnabled = true
        
        submitButton.backgroundColor = .Orange1
    }
    
    func submitButtonDisable() {
        
        submitButton.isEnabled = false
        
        submitButton.backgroundColor = .Gray1
    }
}

extension PublishViewController: ChoosePetViewDelegate {
    
    func didChoosePet(with selectedPet: Pet) {
        
        self.selectedPet = selectedPet
        
        let imageUrl = URL(string: selectedPet.petImage)
        
        petImageView.kf.setImage(with: imageUrl)
        
        petNameLabel.text = selectedPet.name
    }
}
