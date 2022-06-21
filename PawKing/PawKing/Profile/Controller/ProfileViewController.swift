//
//  ProfileViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/14.
//

import UIKit

class ProfileViewController: UIViewController {
    
    let userId = "6jRPSQJEw7NWuyZl2BCs"
    
    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: configureLayout())
    
    private let userManager = UserManager.shared
    
    private let photoHelper = PKPhotoHelper()
    
    var isPhoto = true {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var user: User? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var userPets: [Pet]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var posts: [Post]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        style()
        layout()
    }
    
    private func setup() {
        
        collectionView.dataSource = self
//        collectionView?.delegate = self
        collectionView.register(ProfileInfoCell.self,
                                forCellWithReuseIdentifier: ProfileInfoCell.identifier)
        
        collectionView.register(PetItemCell.self,
                                forCellWithReuseIdentifier: PetItemCell.identifier)
        
        collectionView.register(ContentButtonCell.self,
                                forCellWithReuseIdentifier: ContentButtonCell.identifier)
        
        collectionView.register(PhotoItemCell.self,
                                forCellWithReuseIdentifier: PhotoItemCell.identifier)
        
        collectionView.register(TrackHostoryCell.self,
                                forCellWithReuseIdentifier: TrackHostoryCell.identifier)
        
        navigationItem.title = "個人"
        
        userManager.listenUserInfo(userId: userId) { [weak self] result in
            
            switch result {
                
            case .success(let user):
                
                self?.user = user
                
                self?.userManager.listenPetChange(userId: user.id) { result in
                    
                    switch result {
                        
                    case .success(let pets):
                        
                        self?.userPets = pets
                        
                    case .failure(let error):
                        
                        print(error)
                    }
                }
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    private func style() {
        
        view.backgroundColor = .systemBackground
    }
    
    private func layout() {
        
        view.addSubview(collectionView)
        
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                               leading: view.leadingAnchor,
                               bottom: view.safeAreaLayoutGuide.bottomAnchor,
                               trailing: view.trailingAnchor)
        
    }
    
    private static func configureLayout() -> UICollectionViewCompositionalLayout {
        
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            
            let section = ProfileSections.allCases[sectionIndex]
            
            switch section {
                
            case .userInfo:
                
                let infoItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                          heightDimension: .fractionalHeight(1))
                let infoItem = NSCollectionLayoutItem(layoutSize: infoItemSize)
                
                let infoGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                           heightDimension: .absolute(150))
                let infoGroup = NSCollectionLayoutGroup.vertical(layoutSize: infoGroupSize, subitems: [infoItem])
                
                let infoSection = NSCollectionLayoutSection(group: infoGroup)
                
                return infoSection
                
            case .choosePet:
                
                let petItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                         heightDimension: .fractionalHeight(1))
                let petItem = NSCollectionLayoutItem(layoutSize: petItemSize)
                
                let petGroupSize = NSCollectionLayoutSize(widthDimension: .absolute(80),
                                                          heightDimension: .absolute(80))
                
                let petGroup = NSCollectionLayoutGroup.horizontal(layoutSize: petGroupSize, subitems: [petItem])
                
                let petSection = NSCollectionLayoutSection(group: petGroup)
                
                petSection.orthogonalScrollingBehavior = .continuous
                petSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20)
                
                petSection.interGroupSpacing = 10
                
                return petSection
                
            case .chooseContent:
                
                let chooseItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                            heightDimension: .fractionalHeight(1))
                let chooseItem = NSCollectionLayoutItem(layoutSize: chooseItemSize)
                
                let chooseGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                             heightDimension: .absolute(50))
                let chooseGroup = NSCollectionLayoutGroup.horizontal(layoutSize: chooseGroupSize, subitems: [chooseItem])
                
                let chooseSection = NSCollectionLayoutSection(group: chooseGroup)
                
                chooseSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
                
                return chooseSection
                
            case .postsPhoto:
                    
                let postItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 3),
                                                          heightDimension: .fractionalHeight(1))
                let postItem = NSCollectionLayoutItem(layoutSize: postItemSize)
                
                postItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 10, trailing: 5)
                
                let postGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                           heightDimension: .fractionalWidth(1 / 3))
                let postGroup = NSCollectionLayoutGroup.horizontal(layoutSize: postGroupSize, subitems: [postItem])
                
                let postSection = NSCollectionLayoutSection(group: postGroup)
                
                return postSection

            }
        }
    }
}

extension ProfileViewController: ProfileInfoCellDelegate {
    
    func didTapUserImage() {
        
        photoHelper.presentActionSheet(from: self)
    }
    
    func didTapEditProfile() {
        
        guard let user = user else { return }
        
        let editUserVC = EditUserViewController(userId: user.id, userName: user.name)
        
        navigationController?.pushViewController(editUserVC, animated: true)
    }
    
    func didTapAddPet() {
        
        guard let user = user else { return }
        
        let petConfigVC = PetConfigViewController(user: user, isInitailSet: false)
        
        navigationController?.pushViewController(petConfigVC, animated: true)
    }
}

extension ProfileViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        ProfileSections.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        switch section {
            
        case ProfileSections.userInfo.rawValue:
            
            return user == nil ? 0 : 1
            
        case ProfileSections.choosePet.rawValue:
            
            return userPets?.count ?? 0
//            return 10

        case ProfileSections.chooseContent.rawValue:
            
            return user == nil ? 0 : 1
            
        case ProfileSections.postsPhoto.rawValue:
            
            return posts?.count ?? 15
            
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
            
        case ProfileSections.userInfo.rawValue:
            
            guard let infoCell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileInfoCell.identifier,
                                                                    for: indexPath) as? ProfileInfoCell
            else {
                fatalError("Cannot dequeue ProfileInfoCell")
            }
            
            guard let user = user else { return infoCell }
            
            photoHelper.completionHandler = { [weak self] image in
                
                infoCell.userImageView.image = image
                
                self?.userManager.uploadUserPhoto(userId: user.id,
                                            image: image) { result in
                    switch result {

                    case .success:
                        
                        self?.navigationController?.popToRootViewController(animated: true)
                        
                        self?.userManager.listenUserInfo(userId: user.id) { [weak self] result in
                            
                            switch result {
                                
                            case .success(let user):
                                
                                self?.user = user
                                
                            case .failure(let error):
                                
                                print(error)
                            }
                        }
                        
                    case .failure(let error):
                        
                        print(error)
                    }
                }
            }
            
            infoCell.configureCell(user: user)
            
            infoCell.delegate = self
            
            return infoCell
            
        case ProfileSections.choosePet.rawValue:
            
            guard let petCell = collectionView.dequeueReusableCell(withReuseIdentifier: PetItemCell.identifier,
                                                                    for: indexPath) as? PetItemCell
            else {
                fatalError("Cannot dequeue PhotoItemCell")
            }
            
            guard let userPets = userPets else { return petCell }

            let imageUrl = URL(string: userPets[indexPath.item].petImage)
            
            petCell.photoURL = imageUrl
//            petCell.imageView.image = UIImage.asset(.Image_Placeholder)
            
//            petCell.layoutIfNeeded()
//            petCell.imageView.makeRound()
//            petCell.imageView.clipsToBounds = true
            petCell.configureCell()
            
            return petCell
            
        case ProfileSections.chooseContent.rawValue:
            
            guard let chooseCell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentButtonCell.identifier,
                                                                    for: indexPath) as? ContentButtonCell
            else {
                fatalError("Cannot dequeue ContentButtonCell")
            }
            
            return chooseCell
            
        case ProfileSections.postsPhoto.rawValue:
            
            if isPhoto {
                
                guard let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoItemCell.identifier,
                                                                        for: indexPath) as? PhotoItemCell
                else {
                    fatalError("Cannot dequeue PhotoItemCell")
                }
                
                photoCell.imageView.image = UIImage.asset(.Image_Placeholder)
                
                return photoCell
                
            } else {
                
                guard let trackCell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackHostoryCell.identifier, for: indexPath) as? TrackHostoryCell
                else {
                    fatalError("Cannot dequeue TrackHostoryCell")
                }
                
                return trackCell
            }
        default:
            return UICollectionViewCell()
        }
    }
}
