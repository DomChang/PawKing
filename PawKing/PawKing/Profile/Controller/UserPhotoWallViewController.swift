//
//  UserPhotoWallViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/25.
//

import UIKit
import FirebaseFirestore

class UserPhotoWallViewController: UIViewController {

    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: configureLayout())
    
    private let userManager = UserManager.shared
    
    private let postManager = PostManager.shared
    
    private let lottie = LottieWrapper.shared
    
    private var user = UserManager.shared.currentUser
    
    private var otherUserId: String
    
    private var otherUser: User?
    
    private var otherUserListener: ListenerRegistration?
    
    private var otherUserPets: [Pet]? {
        didSet {
            collectionView.reloadSections(IndexSet(integer: 1))
        }
    }
    
    private var posts: [Post]? {
        didSet {
            collectionView.reloadSections(IndexSet(integer: 2))
            collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
        }
    }
    
    private var displayPosts: [Post]? {
        didSet {
            collectionView.reloadSections(IndexSet(integer: 2))
        }
    }
    
    private var selectedPetIndex: Int?
    
    private var isFriend = false {
        didSet {
            collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    private let actionController = UIAlertController(title: "Actions", message: nil, preferredStyle: .actionSheet)
    
    private let disconnectActionController = UIAlertController(title: "Are you sure you want to disconnect?",
                                                     message: nil,
                                                     preferredStyle: .alert)
    
    init(otherUserId: String) {

        self.otherUserId = otherUserId

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = user {
            
            setActionSheet(user: user)
        }
        
        setup()
        style()
        layout()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//
//        if let user = UserManager.shared.currentUser,
//            let otherUser = otherUser {
//
//            self.user = user
//
//            setActionSheet(user: user)
//        }
//    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        otherUserListener?.remove()
    }
    
    private func setup() {
        
        listenOtherUser()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapAction))
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
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
        
        collectionView.collectionViewLayout.register(OtherUserPetReusableView.self,
                                                     forDecorationViewOfKind: "\(OtherUserPetReusableView.self)")
        
        collectionView.register(PhotoItemCell.self,
                                forCellWithReuseIdentifier: PhotoItemCell.identifier)
    }
    
    private func style() {
        
        view.backgroundColor = .systemBackground
    }
    
    private func layout() {
        
        view.addSubview(collectionView)
        
        collectionView.fillSafeLayout()
        
        // Change top bounce area backgroud color
        collectionView.layoutIfNeeded()
        let topView = UIView(frame: CGRect(x: 0, y: -collectionView.bounds.height,
                width: collectionView.bounds.width, height: collectionView.bounds.height))
        topView.backgroundColor = .BattleGrey
        collectionView.addSubview(topView)
    }
    
    func listenOtherUser() {
        
        if otherUserListener != nil {
            
            otherUserListener?.remove()
        }
        
        lottie.startLoading()
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dispatchQueue = DispatchQueue.global()
        
        dispatchQueue.async { [weak self] in
            
            guard let otherUserId = self?.otherUserId else { return }
            
            self?.otherUserListener =  self?.userManager.listenUserInfo(userId: otherUserId,
                                                                        completion: { result in
                
                switch result {
                    
                case .success(let otherUser):
                    
                    self?.user = UserManager.shared.currentUser
                    
                    self?.otherUser = otherUser
                    
                    semaphore.signal()
                    
                    self?.navigationItem.title = "\(otherUser.name)"
                    
                    self?.fetchPet(by: otherUser)
                    
                    self?.fetchPost(by: otherUser)
                    
                case .failure(let error):
                    
                    self?.lottie.stopLoading()
                    
                    self?.lottie.showError(error)
                    
                    semaphore.signal()
                }
            })
            
            semaphore.wait()
            
            guard let user = self?.user else {
                return
            }
            
            self?.setActionSheet(user: user)
            self?.setDisconnectAlert()
        }
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
                
                self?.lottie.stopLoading()
                
                self?.posts = posts
                self?.displayPosts = posts
                
            case .failure(let error):
                
                self?.lottie.stopLoading()
                
                print(error)
            }
        }
    }
    
    func setConnectState(sender: UIButton) {
        
        guard let user = user,
              let otherUser = otherUser else {
            return
        }
        
        if otherUser.friends.contains(user.id) {
            
            isFriend = true
            
            sender.isSelected = true
            
        } else if otherUser.recieveRequestsId.contains(user.id) {
            
            isFriend = false
            
            sender.isSelected = true
            
        } else {
            
            isFriend = false
            
            sender.isSelected = false
        }
    }
    
    func setConnectButtonColor(sender: UIButton) {
        
        if sender.isSelected {
            
            sender.backgroundColor = .BattleGrey
            
            sender.layer.borderWidth = 1
            
        } else {
            sender.backgroundColor = .Orange1
            
            sender.layer.borderWidth = 0
        }
    }
    
    func setActionSheet(user: User) {
        
        guard let otherUser = otherUser else {
            return
        }
        
        if user.blockUsersId.contains(otherUser.id) {

            let unBlockAction = UIAlertAction(title: "Unblock User", style: .destructive) { [weak self] _ in
                
                guard let self = self else { return }
                
                self.userManager.removeBlockUser(userId: user.id, blockId: self.otherUserId) { result in
                    
                    switch result {
                        
                    case.success:
                        
                        print("Unblock user success!")
                        
                    case .failure(let error):
                        
                        print(error)
                    }
                }
            }
            DispatchQueue.main.async {
                self.actionController.addAction(unBlockAction)
            }
        } else {
            
            let blockAction = UIAlertAction(title: "Block User", style: .destructive) { [weak self] _ in
                
                guard let self = self else { return }
                
                self.userManager.addBlockUser(userId: user.id, blockId: self.otherUserId) { result in
                    
                    switch result {
                        
                    case.success:
                        
                        print("Block user success!")
                        
                    case .failure(let error):
                        
                        print(error)
                    }
                }
            }
            DispatchQueue.main.async {
                self.actionController.addAction(blockAction)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        DispatchQueue.main.async {
            self.actionController.addAction(cancelAction)
        }
    }
    
    func setDisconnectAlert() {
        
        guard let user = user,
              let otherUser = otherUser else {
            return
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        let disconnectAlert  = UIAlertAction(title: "Disconnect", style: .destructive) { [weak self] _ in
            
            self?.userManager.removeFriend(userId: user.id, friendId: otherUser.id) { result in
                switch result {
                    
                case .success:
                    
                    print("disconnected")
                    
                case .failure(let error):
                    
                    print(error)
                }
            }
        }
        DispatchQueue.main.async {
            self.disconnectActionController.addAction(cancelAction)
            self.disconnectActionController.addAction(disconnectAlert)
        }
    }
    
    @objc func didTapAction() {
        
        present(actionController, animated: true) {
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            
            self.actionController.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func dismissAlertController() {
        
        actionController.dismiss(animated: true)
    }
}

extension UserPhotoWallViewController: ProfileInfoCellDelegate {
    
    func didTapLeftButton(from cell: ProfileInfoCell) {
        
        guard let user = user,
              let otherUser = otherUser else {
            
            lottie.showError(nil)
            
            return
        }
        
        let friendRequestButton = cell.leftButton
        
        // state: requested or friend
        if friendRequestButton.isSelected {
            
            if isFriend {
                // show disConnect alert
                
                present(disconnectActionController, animated: true)
                
            } else {
                // requested
                
                friendRequestButton.isSelected = !friendRequestButton.isSelected
                
                userManager.removeFriendRequest(senderId: user.id, recieverId: otherUser.id) { [weak self] result in
                    
                    switch result {
                        
                    case .success:
                        
                        print("remove request success!")
                        
                    case .failure(let error):
                        
                        self?.lottie.showError(error)
                    }
                }
            }
            
        } else {
            // send request
            
            friendRequestButton.isSelected = !friendRequestButton.isSelected
            
            userManager.sendFriendRequest(senderId: user.id,
                                          recieverId: otherUser.id,
                                          recieverBlockIds: otherUser.blockUsersId) { [weak self] result in
                
                switch result {
                    
                case .success:
                    
                    print("send request success!")
                    
                case .failure(let error):
                    
                    self?.lottie.showError(error)
                }
            }
        }
        
        setConnectButtonColor(sender: friendRequestButton)
    }
    
    func didTapRightButton() {
        
        guard let user = user,
              let otherUser = otherUser else {
            return
        }

       let messageVC = MessageViewController(user: user,
                                             otherUser: otherUser, otherUserId: otherUser.id)
        
        navigationController?.pushViewController(messageVC, animated: true)
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
                    elementKind: "\(OtherUserPetReusableView.self)")

                petSection.decorationItems = [petItemBackView]
                
                return petSection
                
            case .postsPhoto:
                    
                let postItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 3),
                                                          heightDimension: .fractionalHeight(1))
                let postItem = NSCollectionLayoutItem(layoutSize: postItemSize)
                
                postItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 1, bottom: 2, trailing: 1)
                
                let postGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                           heightDimension: .fractionalWidth(1 / 3))
                let postGroup = NSCollectionLayoutGroup.horizontal(layoutSize: postGroupSize, subitems: [postItem])
                
                let postSection = NSCollectionLayoutSection(group: postGroup)
                
                postSection.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 2, bottom: 0, trailing: 2)
                
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
            infoCell.leftButton.setTitleColor(.white, for: .normal)
            
            setConnectState(sender: infoCell.leftButton)
            
            if isFriend {
                infoCell.leftButton.setTitle("Disconnect", for: .selected)
            } else {
                infoCell.leftButton.setTitle("Requested", for: .selected)
            }
            
            setConnectButtonColor(sender: infoCell.leftButton)
            
            infoCell.rightButton.setTitle("Send Message", for: .normal)
            
            if let otherUser = otherUser {
                infoCell.configureCell(user: otherUser, postCount: posts?.count ?? 0)
            }
            
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
                    let userPets = otherUserPets,
                    let cell = collectionView.cellForItem(at: indexPath) as? PetItemCell else {
                return
            }
            
            collectionView.visibleCells.forEach { cell in
                guard let petCell = cell as? PetItemCell else { return }
                
                petCell.imageView.layer.borderWidth = 0
                
                petCell.backBorderView.isHidden = true
            }
            
            if selectedPetIndex != indexPath.item {
                
                displayPosts = posts.filter { $0.petId == userPets[indexPath.item].id }
                
                selectedPetIndex = indexPath.item
                
                cell.imageView.layer.borderWidth = 2
                cell.imageView.layer.borderColor = UIColor.BattleGrey?.cgColor
                cell.backBorderView.isHidden = false
                
            } else {
                
                cell.imageView.layer.borderWidth = 0
                cell.backBorderView.isHidden = true

                displayPosts = posts
                
                selectedPetIndex = -1
            }
        } else if indexPath.section == UserPhotoWallSections.postsPhoto.rawValue {
         
            guard  let user = user,
                   let post = posts?[indexPath.item] else { return }
            
            let photoPostVC = PhotoPostViewController(user: user, post: post)
            
            navigationController?.pushViewController(photoPostVC, animated: true)
            
        }
    }
}
