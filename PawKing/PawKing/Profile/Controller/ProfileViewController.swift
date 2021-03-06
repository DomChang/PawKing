//
//  ProfileViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/14.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: configureLayout())
    
    private let userManager = UserManager.shared
    
    private let postManager = PostManager.shared
    
    private let photoHelper = PKPhotoHelper()
    
    private let lottie = LottieWrapper.shared
    
    var isPhoto = true {
        didSet {
            collectionView.reloadSections(IndexSet(integer: 3))
            checkIsEmpty()
        }
    }
    
    var user: User?
    
    var userPets: [Pet]? {
        didSet {
            collectionView.reloadSections(IndexSet(integer: 1))
        }
    }
    
    var posts: [Post]? {
        didSet {
            collectionView.reloadSections(IndexSet(integer: 3))
            collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
        }
    }
    
    var displayPosts: [Post]? {
        didSet {
            collectionView.reloadSections(IndexSet(integer: 3))
            checkIsEmpty()
        }
    }
    
    var trackInfos: [TrackInfo]? {
        didSet {
            collectionView.reloadSections(IndexSet(integer: 3))
        }
    }
    
    var displayTrackInfos: [TrackInfo]? {
        didSet {
            collectionView.reloadSections(IndexSet(integer: 3))
            checkIsEmpty()
        }
    }
    
    private var selectedPetIndex: IndexPath?
    
    private let emptyLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        style()
        layout()
        
    }

    private func setup() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fetchUser),
                                               name: .updateUser,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fetchUser),
                                               name: .updateTrackHistory,
                                               object: nil)
        
        fetchUser()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.asset(.Icons_24px_Setting),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapSetting))
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.allowsSelection = true
        collectionView.isUserInteractionEnabled = true
        
        collectionView.register(ProfileInfoCell.self,
                                forCellWithReuseIdentifier: ProfileInfoCell.identifier)
        
        collectionView.collectionViewLayout.register(ProfileInfoReusableView.self,
                                                     forDecorationViewOfKind: "\(ProfileInfoReusableView.self)")
        
        collectionView.register(PetItemCell.self,
                                forCellWithReuseIdentifier: PetItemCell.identifier)
        
        collectionView.collectionViewLayout.register(PetItemBackReusableView.self,
                                                     forDecorationViewOfKind: "\(PetItemBackReusableView.self)")
        
        collectionView.register(ContentButtonCell.self,
                                forCellWithReuseIdentifier: ContentButtonCell.identifier)
        
        collectionView.collectionViewLayout.register(ContentButtonReusableView.self,
                                                     forDecorationViewOfKind: "\(ContentButtonReusableView.self)")
        
        collectionView.register(PhotoItemCell.self,
                                forCellWithReuseIdentifier: PhotoItemCell.identifier)
        
        collectionView.register(TrackHostoryCell.self,
                                forCellWithReuseIdentifier: TrackHostoryCell.identifier)
    }
    
    private func style() {
        
        navigationController?.navigationBar.tintColor = .white
        
        view.backgroundColor = .BattleGrey
        collectionView.backgroundColor = .white
        collectionView.layer.cornerRadius = 20
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        emptyLabel.textColor = .BattleGreyLight
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
    }
    
    private func layout() {
        
        view.addSubview(collectionView)
        collectionView.addSubview(emptyLabel)
        
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                               leading: view.leadingAnchor,
                               bottom: view.safeAreaLayoutGuide.bottomAnchor,
                               trailing: view.trailingAnchor)
        
        // Change top bounce area backgroud color
        collectionView.layoutIfNeeded()
        let topView = UIView(frame: CGRect(x: 0, y: -collectionView.bounds.height,
                width: collectionView.bounds.width, height: collectionView.bounds.height))
        topView.backgroundColor = .BattleGrey
        collectionView.addSubview(topView)
        
        emptyLabel.anchor(top: collectionView.centerYAnchor,
                          centerX: collectionView.centerXAnchor,
                          padding: UIEdgeInsets(top: 120, left: 0, bottom: 0, right: 0))
        
    }
    
    @objc func didTapSetting() {
        
        let settingVC = SettingViewController()
        
        navigationController?.pushViewController(settingVC, animated: true)
    }
    
    @objc private func fetchUser() {
        
        guard let user = UserManager.shared.currentUser else { return }
        
        lottie.startLoading()
        
        userManager.fetchUserInfo(userId: user.id) { [weak self] result in
            
            switch result {
                
            case .success(let user):
                
                self?.user = user
                
                self?.navigationItem.title = "\(user.name)"
                
                self?.fetchPet(by: user)
                
                self?.fetchPost(by: user)
                
                self?.fetchTrack(by: user)
                
                self?.lottie.stopLoading()
                
            case .failure:
                
                self?.lottie.stopLoading()
            }
        }
    }
    
    func fetchPet(by user: User) {
        
        userManager.fetchPets(userId: user.id) { [weak self] result in
            
            switch result {
                
            case .success(let pets):
                
                self?.userPets = pets
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func fetchPost(by user: User) {
        
        postManager.fetchPosts(userId: user.id) { [weak self] result in
            
            switch result {
                
            case .success(let posts):
                
                self?.selectedPetIndex = nil
                self?.posts = posts
                self?.displayPosts = posts
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func fetchTrack(by user: User) {
        
        userManager.fetchTracks(userId: user.id) { [weak self] result in
            
            switch result {
                
            case .success(let trackInfos):
                
                self?.selectedPetIndex = nil
                self?.trackInfos = trackInfos
                self?.displayTrackInfos = trackInfos
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func checkIsEmpty() {
        
        if isPhoto && displayPosts?.count == 0 {
            
            emptyLabel.text = "Click + to Post"
            emptyLabel.isHidden = false
            
        } else if !isPhoto && displayTrackInfos?.count == 0 {
            
            emptyLabel.text = "No Track"
            emptyLabel.isHidden = false
            
        } else {
            
            emptyLabel.isHidden = true
        }
    }
}

extension ProfileViewController: ProfileInfoCellDelegate {
    
    func didTapFriend() {
        
        guard let friendsId = user?.friends else { return }
        
        let friendListVC = UserListViewController(usersId: friendsId, listType: .friend, postId: nil)
        
        navigationController?.pushViewController(friendListVC, animated: true)
    }
    
    func didTapUserImage() {
        
        photoHelper.presentActionSheet(from: self)
    }
    
    func didTapLeftButton(from cell: ProfileInfoCell) {
        
        guard let user = user else { return }
        
        let editUserVC = EditProfileViewController(user: user)
        
        navigationController?.pushViewController(editUserVC, animated: true)
    }
    
    func didTapRightButton() {
        
        guard let user = user else { return }

        let petConfigVC = PetConfigViewController(user: user,
                                                  editPet: nil,
                                                  isInitailSet:
                                                    false, isEdit: false)
        
        navigationController?.pushViewController(petConfigVC, animated: true)
    }
}

extension ProfileViewController: ContentButtonCellDelegate {
    
    func didTapPhoto() {
        
        isPhoto = true
    }
    
    func didTapTrack() {
        
        isPhoto = false
    }
}

extension ProfileViewController: UICollectionViewDataSource {
    
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
                
                let infoBackView = NSCollectionLayoutDecorationItem.background(
                    elementKind: "\(ProfileInfoReusableView.self)")

                infoSection.decorationItems = [infoBackView]
                
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
                petSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                
                petSection.interGroupSpacing = 10
                
                let petItemBackView = NSCollectionLayoutDecorationItem.background(
                    elementKind: "\(PetItemBackReusableView.self)")

                petSection.decorationItems = [petItemBackView]
                
                return petSection
                
            case .chooseContent:
                
                let chooseItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                            heightDimension: .fractionalHeight(1))
                let chooseItem = NSCollectionLayoutItem(layoutSize: chooseItemSize)
                
                let chooseGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                             heightDimension: .absolute(40))
                let chooseGroup = NSCollectionLayoutGroup.horizontal(layoutSize: chooseGroupSize,
                                                                     subitems: [chooseItem])
                
                let chooseSection = NSCollectionLayoutSection(group: chooseGroup)
                
                chooseSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
                
                let chooseBackView = NSCollectionLayoutDecorationItem.background(
                    elementKind: "\(ContentButtonReusableView.self)")

                chooseSection.decorationItems = [chooseBackView]
                
                return chooseSection
                
            case .postsPhoto:
                    
                let postItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 3),
                                                          heightDimension: .fractionalHeight(1))
                let postItem = NSCollectionLayoutItem(layoutSize: postItemSize)
                
                postItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 1, bottom: 2, trailing: 1)
                
                let postGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                           heightDimension: .fractionalWidth(1 / 3))
                let postGroup = NSCollectionLayoutGroup.horizontal(layoutSize: postGroupSize, subitems: [postItem])
                
                let postSection = NSCollectionLayoutSection(group: postGroup)
                
                postSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2)
                
                return postSection

            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        ProfileSections.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        switch section {
            
        case ProfileSections.userInfo.rawValue:
            
            return 1
            
        case ProfileSections.choosePet.rawValue:
            
            return userPets?.count ?? 0

        case ProfileSections.chooseContent.rawValue:
            
            return 1
            
        case ProfileSections.postsPhoto.rawValue:
            
            if isPhoto {
                return displayPosts?.count ?? 0
            } else {
                return displayTrackInfos?.count ?? 0
            }
            
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
                        
                        print("???????????????????????????")
                        
                    case .failure(let error):
                        
                        self?.lottie.showError(error: error)
                    }
                }
            }
            
            infoCell.leftButton.setTitle("Edit Profile", for: .normal)
            
            infoCell.rightButton.setTitle("Add Pet", for: .normal)
            
            infoCell.configureCell(user: user, postCount: posts?.count ?? 0)
            
            infoCell.delegate = self
            
            return infoCell
            
        case ProfileSections.choosePet.rawValue:
            
            guard let petCell = collectionView.dequeueReusableCell(withReuseIdentifier: PetItemCell.identifier,
                                                                    for: indexPath) as? PetItemCell
            else {
                fatalError("Cannot dequeue PhotoItemCell")
            }
            
            guard let userPets = userPets else { return petCell }

            let userPet = userPets[indexPath.item]
            
            if selectedPetIndex == nil {
                petCell.selectState = false
            }
            petCell.configureCell(pet: userPet)
            
            return petCell
            
        case ProfileSections.chooseContent.rawValue:
            
            guard let chooseCell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentButtonCell.identifier,
                                                                    for: indexPath) as? ContentButtonCell
            else {
                fatalError("Cannot dequeue ContentButtonCell")
            }
            chooseCell.delegate = self
            
            return chooseCell
            
        case ProfileSections.postsPhoto.rawValue:
            
            if isPhoto {
                
                guard let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoItemCell.identifier,
                                                                        for: indexPath) as? PhotoItemCell
                else {
                    fatalError("Cannot dequeue PhotoItemCell")
                }
                
                photoCell.imageView.image = UIImage.asset(.Image_Placeholder_Paw)
                
                guard let posts = displayPosts else { return photoCell }
                
                let imageUrl = URL(string: posts[indexPath.item].photo)
                
                photoCell.imageView.kf.setImage(with: imageUrl)
                
                return photoCell
                
            } else {
                
                guard let trackCell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TrackHostoryCell.identifier,
                    for: indexPath
                ) as? TrackHostoryCell
                        
                else {
                    fatalError("Cannot dequeue TrackHostoryCell")
                }
                
                guard let trackInfos = displayTrackInfos,
                        let userPets = userPets else { return trackCell }
                
                let trackInfo = trackInfos[indexPath.item]
                
                for userPet in userPets where userPet.id == trackInfo.petId {
                    
                    trackCell.configureCell(pet: userPet, trackInfo: trackInfo)
                }
                return trackCell
            }
        default:
            return UICollectionViewCell()
        }
    }
}

extension ProfileViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == ProfileSections.choosePet.rawValue {
            
            guard let posts = posts,
                    let trackInfos = trackInfos,
                    let userPets = userPets,
                    let cell = collectionView.cellForItem(at: indexPath) as? PetItemCell
            else {
                return
            }
            
            if let selectedPetIndex = selectedPetIndex {
                
                guard let selectedCell = collectionView.cellForItem(at: selectedPetIndex) as? PetItemCell
                else {
                    return
                }
                
                if selectedPetIndex == indexPath {
                    
                    selectedCell.selectState = !selectedCell.selectState
                } else {
                    
                    selectedCell.selectState = false
                    cell.selectState = !cell.selectState
                }
            } else {
                
                cell.selectState = !cell.selectState
            }
            
            if cell.selectState {
                
                displayPosts = posts.filter { $0.petId == userPets[indexPath.item].id }
                
                displayTrackInfos = trackInfos.filter { $0.petId == userPets[indexPath.item].id }
                
                selectedPetIndex = indexPath
                
            } else {
                
                displayPosts = posts
                
                displayTrackInfos = trackInfos
                
                selectedPetIndex = nil
                
            }
        } else if indexPath.section == ProfileSections.postsPhoto.rawValue {
            
            if isPhoto {
                
                guard let user = user,
                      let post = displayPosts?[indexPath.item]
                else { return }
                
                if let selectedIndex = selectedPetIndex {
                    
                    guard let cell = collectionView.cellForItem(at: selectedIndex) as? PetItemCell
                    else {
                        return
                    }
                    cell.selectState = true
                    cell.isSelected = true
                }
                
                let photoPostVC = PhotoPostViewController(user: user, post: post)
                
                navigationController?.pushViewController(photoPostVC, animated: true)
                
            } else {
                
                guard let trackInfos = displayTrackInfos,
                        let userPets = userPets else {
                    return
                }
                
                if let selectedIndex = selectedPetIndex {
                    
                    guard let cell = collectionView.cellForItem(at: selectedIndex) as? PetItemCell
                    else {
                        return
                    }
                    cell.selectState = true
                    cell.isSelected = false
                }

                let trackInfo = trackInfos[indexPath.item]
                
                for userPet in userPets where userPet.id == trackInfo.petId {
                    
                    let trackHistoryVC = TrackHistoryViewController(pet: userPet,
                                                                    trackInfo: trackInfo,
                                                                    isNew: false)
                    
                    navigationController?.pushViewController(trackHistoryVC, animated: true)
                }
            }
        }
    }
}
