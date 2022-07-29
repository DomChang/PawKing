//
//  UserPhotoWallViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/25.
//

import UIKit
import FirebaseFirestore

class UserPhotoWallViewController: UserProfileBaseViewController {
    
    private var otherUserId: String
    
    private var otherUser: User?
    
    private var otherUserListener: ListenerRegistration?
    
    private var connectStatus = UserConnectStatus.connect {
        didSet {
            collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    private let alertHelper = AlertHelper()
 
    init(otherUserId: String) {

        self.otherUserId = otherUserId

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        otherUserListener?.remove()
    }
    
    override func setup() {
        
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout:
                UICollectionViewCompositionalLayout.userPhotoWallCompositionalLayout()
        )
        
        collectionView.collectionViewLayout.register(OtherUserPetReusableView.self,
                                                     forDecorationViewOfKind: "\(OtherUserPetReusableView.self)")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        super.setup()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapAction))
        
        listenOtherUser()
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
                    
                    self?.lottie.stopLoading()
                    
                case .failure(let error):
                    
                    self?.lottie.stopLoading()
                    
                    self?.lottie.showError(error: error)
                    
                    semaphore.signal()
                }
            })
            semaphore.wait()
        }
    }
    
    override func checkIsEmpty() {
        
        if displayPosts?.count == 0 {
            
            emptyLabel.text = "No Post"
            emptyLabel.isHidden = false
            
        } else {
            
            emptyLabel.isHidden = true
        }
    }
    func setConnectState() {
        
        guard let user = user,
              let otherUser = otherUser else {
            return
        }
        
        if otherUser.friends.contains(user.id) {
            
            connectStatus = .disconnect
            
        } else if otherUser.recieveRequestsId.contains(user.id) {
            
            connectStatus = .requested
            
        } else {
            
            connectStatus = .connect
        }
    }
    
    private func setBlockAction(user: User) {
        
        userManager.removeBlockUser(userId: user.id,
                                    blockId: otherUserId) { result in
            
            switch result {
                
            case.success:
                
                print("Unblock user success!")
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    private func setUnblockAction(user: User) {

        userManager.addBlockUser(userId: user.id,
                                      blockId: otherUserId) { result in
            
            switch result {
                
            case.success:
                
                print("Block user success!")
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    private func setDisconnectAction() {
        
        guard let user = UserManager.shared.currentUser,
              let otherUser = otherUser else {
            return
        }
        
        userManager.removeFriend(userId: user.id,
                                 friendId: otherUser.id) { [weak self] result in
            switch result {
                
            case .success:
                
                self?.connectStatus = .connect
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    @objc func didTapAction() {
        
        guard let user = UserManager.shared.currentUser,
                let otherUser = otherUser
        else {
            return
        }
        
        if user.blockUsersId.contains(otherUser.id) {
        
            alertHelper.showActionSheet(title: nil,
                                  message: nil,
                                  actionName: "Unblock",
                                  actionStyle: .default,
                                  action: { self.setBlockAction(user: user) },
                                  by: self)
            
        } else {
            
            alertHelper.showActionSheet(title: nil,
                                        message: nil,
                                        actionName: "Block",
                                        actionStyle: .destructive,
                                        action: { self.setUnblockAction(user: user) },
                                        by: self)
        }
    }
}

extension UserPhotoWallViewController: UserInfoCellDelegate {
    
    func didTapFriend() {
        
        guard let friendsId = otherUser?.friends else { return }
        
        let friendListVC = FriendListViewController(usersId: friendsId)
        
        navigationController?.pushViewController(friendListVC, animated: true)
    }
    
    func didTapLeftButton() {
        
        guard let user = user,
              let otherUser = otherUser else {
            
            lottie.showError(error: nil)
            
            return
        }
        switch connectStatus {
            
        case .connect:
            
            userManager.sendFriendRequest(senderId: user.id,
                                          recieverId: otherUser.id,
                                          recieverBlockIds: otherUser.blockUsersId) { [weak self] result in
                switch result {
                    
                case .success:
                    
                    self?.connectStatus = .requested
                    
                case .failure(let error):
                    
                    self?.lottie.showError(error: error)
                }
            }
            
        case .requested:
            
            userManager.removeFriendRequest(senderId: user.id, recieverId: otherUser.id) { [weak self] result in
                
                switch result {
                    
                case .success:
                    
                    self?.connectStatus = .connect
                    
                case .failure(let error):
                    
                    self?.lottie.showError(error: error)
                }
            }
            
        case .disconnect:
            
            alertHelper.showAlert(title: "Are you sure you want to disconnect?",
                                  message: nil,
                                  actionName: "Disconnect",
                                  actionStyle: .destructive,
                                  action: { self.setDisconnectAction() },
                                  by: self)
        }
        selectedPetIndex = nil
    }
    
    func didTapRightButton() {
        
        guard let user = user,
              let otherUser = otherUser else { return }

       let messageVC = MessageViewController(user: user,
                                             otherUser: otherUser, otherUserId: otherUser.id)
        
        navigationController?.pushViewController(messageVC, animated: true)
    }
}

extension UserPhotoWallViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        UserPhotoWallSections.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        switch section {
            
        case UserPhotoWallSections.userInfo.rawValue:
            
            return 1
            
        case UserPhotoWallSections.choosePet.rawValue:
            
            return pets?.count ?? 0
            
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
            
            guard let infoCell = collectionView.dequeueReusableCell(withReuseIdentifier: OtherUserInfoCell.identifier,
                                                                    for: indexPath) as? OtherUserInfoCell
            else {
                fatalError("Cannot dequeue ProfileInfoCell")
            }
            
            setConnectState()

            if let otherUser = otherUser {

                infoCell.configureCell(user: otherUser, postCount: posts?.count ?? 0, connectStatus: connectStatus)
            }
            
            infoCell.delegate = self
            
            return infoCell
            
        case UserPhotoWallSections.choosePet.rawValue:
            
            guard let petCell = collectionView.dequeueReusableCell(withReuseIdentifier: PetItemCell.identifier,
                                                                    for: indexPath) as? PetItemCell
            else {
                fatalError("Cannot dequeue PhotoItemCell")
            }
            
            guard let otherUserPets = pets else { return petCell }

            let otherUserPet = otherUserPets[indexPath.item]
            
            if selectedPetIndex == nil {
                petCell.selectState = false
            }
            petCell.configureCell(pet: otherUserPet)
            
            return petCell
            
        case UserPhotoWallSections.postsPhoto.rawValue:
                
            guard let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoItemCell.identifier,
                                                                    for: indexPath) as? PhotoItemCell
            else {
                fatalError("Cannot dequeue PhotoItemCell")
            }
            
            guard let posts = displayPosts,
                    let imageUrl = URL(string: posts[indexPath.item].photo)
            else {
                return photoCell
            }
            
            photoCell.configureCell(photoURL: imageUrl)
            
            return photoCell
                
        default:
            return UICollectionViewCell()
        }
    }
}

extension UserPhotoWallViewController: UICollectionViewDelegate {
    
    private func updateDisplayContent(isFilter: Bool, filterIndex: IndexPath) {
        
        guard let userPets = pets,
              let posts = posts
        else {
            return
        }
        
        if isFilter {
            
            displayPosts = posts.filter { $0.petId == userPets[filterIndex.item].id }
            
            selectedPetIndex = filterIndex
            
        } else {
            
            displayPosts = posts
            
            selectedPetIndex = nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == UserPhotoWallSections.choosePet.rawValue {
            
            guard let cell = collectionView.cellForItem(at: indexPath)
                    as? PetItemCell
            else {
                return
            }
            if let selectedPetIndex = selectedPetIndex {
                
                guard let selectedCell = collectionView.cellForItem(at: selectedPetIndex)
                        as? PetItemCell
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
            updateDisplayContent(isFilter: cell.selectState, filterIndex: indexPath)
            
        } else if indexPath.section == UserPhotoWallSections.postsPhoto.rawValue {
         
            guard  let user = user,
                   let post = displayPosts?[indexPath.item] else { return }
            
            let photoPostVC = PhotoPostViewController(user: user, post: post)
            
            navigationController?.pushViewController(photoPostVC, animated: true)
        }
    }
}
