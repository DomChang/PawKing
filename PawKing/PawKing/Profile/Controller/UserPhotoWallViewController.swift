//
//  UserPhotoWallViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/25.
//

import UIKit

class UserPhotoWallViewController: UIViewController {

    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: configureLayout())
    
    private let userManager = UserManager.shared
    
    private let postManager = PostManager.shared
    
    var user: User
    
    var otherUser: User
    
    var otherUserPets: [Pet]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var posts: [Post]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var displayPosts: [Post]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var selectedPetIndex: Int?
    
    init(user: User, otherUser: User) {
        
        self.user = user
        
        self.otherUser = otherUser
        
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
        
        collectionView.dataSource = self
        
        collectionView.delegate = self
        
        collectionView.allowsSelection = true
        
        collectionView.isUserInteractionEnabled = true
        
        collectionView.register(ProfileInfoCell.self,
                                forCellWithReuseIdentifier: ProfileInfoCell.identifier)
        
        collectionView.register(PetItemCell.self,
                                forCellWithReuseIdentifier: PetItemCell.identifier)
        
        collectionView.register(PhotoItemCell.self,
                                forCellWithReuseIdentifier: PhotoItemCell.identifier)
        
        fetchPet(by: otherUser)
        
        fetchPost(by: otherUser)
    }
    
    private func style() {
        
        view.backgroundColor = .systemBackground
    }
    
    private func layout() {
        
        view.addSubview(collectionView)
        
        collectionView.fillSafeLayout()
        
    }
    
    func fetchPet(by otherUser: User) {
        
        userManager.fetchPets(userId: otherUser.id) { [weak self] result in
            
            switch result {
                
            case .success(let pets):
                
                self?.otherUserPets = pets
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func fetchPost(by otherUser: User) {
        
        postManager.fetchPosts(userId: otherUser.id) { [weak self] result in
            
            switch result {
                
            case .success(let posts):
                
                self?.posts = posts
                self?.displayPosts = posts
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
}

extension UserPhotoWallViewController: ProfileInfoCellDelegate {
    
    func didTapLeftButton() {
        
      
    }
    
    func didTapRightButton() {

       let messageVC = MessageViewController(user: user,
                                             otherUser: otherUser)
        
        let navMessage = UINavigationController(rootViewController: messageVC)
        
        navMessage.modalPresentationStyle = .overFullScreen
        
        navigationController?.present(navMessage, animated: true)
    }
}

extension UserPhotoWallViewController: UICollectionViewDataSource {
    
    private static func configureLayout() -> UICollectionViewCompositionalLayout {
        
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            
            let section = UserPhotoWallSections.allCases[sectionIndex]
            
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
                
            case .postsPhoto:
                    
                let postItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 3),
                                                          heightDimension: .fractionalHeight(1))
                let postItem = NSCollectionLayoutItem(layoutSize: postItemSize)
                
                postItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 1, bottom: 10, trailing: 10)
                
                let postGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                           heightDimension: .fractionalWidth(1 / 3))
                let postGroup = NSCollectionLayoutGroup.horizontal(layoutSize: postGroupSize, subitems: [postItem])
                
                let postSection = NSCollectionLayoutSection(group: postGroup)
                
                postSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                
                return postSection

            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        UserPhotoWallSections.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        switch section {
            
        case UserPhotoWallSections.userInfo.rawValue:
            
            return 1
            
        case UserPhotoWallSections.choosePet.rawValue:
            
            return otherUserPets?.count ?? 0
            
        case UserPhotoWallSections.postsPhoto.rawValue:
            
            return displayPosts?.count ?? 0
   
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
            
        case UserPhotoWallSections.userInfo.rawValue:
            
            guard let infoCell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileInfoCell.identifier,
                                                                    for: indexPath) as? ProfileInfoCell
            else {
                fatalError("Cannot dequeue ProfileInfoCell")
            }
            
            infoCell.leftButton.setTitle("Connect", for: .normal)
            
            infoCell.rightButton.setTitle("Send Message", for: .normal)
            
            infoCell.configureCell(user: otherUser)
            
            infoCell.delegate = self
            
            return infoCell
            
        case UserPhotoWallSections.choosePet.rawValue:
            
            guard let petCell = collectionView.dequeueReusableCell(withReuseIdentifier: PetItemCell.identifier,
                                                                    for: indexPath) as? PetItemCell
            else {
                fatalError("Cannot dequeue PhotoItemCell")
            }
            
            guard let otherUserPets = otherUserPets else { return petCell }

            let imageUrl = URL(string: otherUserPets[indexPath.item].petImage)
            
            petCell.photoURL = imageUrl
            
            petCell.configureCell()
            
            return petCell
            
        case UserPhotoWallSections.postsPhoto.rawValue:
                
            guard let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoItemCell.identifier,
                                                                    for: indexPath) as? PhotoItemCell
            else {
                fatalError("Cannot dequeue PhotoItemCell")
            }
            
            photoCell.imageView.image = UIImage.asset(.Image_Placeholder)
            
            guard let posts = displayPosts else { return photoCell }
            
            let imageUrl = URL(string: posts[indexPath.item].photo)
            
            photoCell.imageView.kf.setImage(with: imageUrl)
            
            return photoCell
                
        default:
            return UICollectionViewCell()
        }
    }
}

extension UserPhotoWallViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == UserPhotoWallSections.choosePet.rawValue {
            
            guard let posts = posts,
                    let userPets = otherUserPets else {
                return
            }
            
            if selectedPetIndex != indexPath.item {
                
                displayPosts = posts.filter { $0.petId == userPets[indexPath.item].id }
                
                selectedPetIndex = indexPath.item
                
            } else {

                displayPosts = posts
                
                selectedPetIndex = -1
            }
        } else if indexPath.section == UserPhotoWallSections.postsPhoto.rawValue {
         
            guard let post = posts?[indexPath.item] else { return }
            
            let photoPostVC = PhotoPostViewController(user: user, post: post)
            
            navigationController?.pushViewController(photoPostVC, animated: true)
            
        }
    }
}
