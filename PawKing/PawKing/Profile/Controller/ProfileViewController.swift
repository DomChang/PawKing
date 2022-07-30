//
//  ProfileViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/14.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UserProfileBaseViewController {

    override func setup() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fetchUser),
                                               name: .updateUser,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fetchUser),
                                               name: .updateTrackHistory,
                                               object: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.asset(.Icons_24px_Setting),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapSetting))
        
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout.profileViewCompositionalLayout()
        )
        
        super.setup()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        fetchUser()
    }
    
    @objc func didTapSetting() {
        
        let settingVC = SettingViewController()
        
        navigationController?.pushViewController(settingVC, animated: true)
    }
    
    @objc private func fetchUser() {
        
        guard let user = UserManager.shared.currentUser else { return }
        
        LottieWrapper.shared.startLoading()
        
        UserManager.shared.fetchUserInfo(userId: user.id) { [weak self] result in
            
            switch result {
                
            case .success(let user):
                
                self?.user = user
                
                self?.navigationItem.title = "\(user.name)"
                
                self?.fetchPet(by: user)
                
                self?.fetchPost(by: user)
                
                self?.fetchTrack(by: user)
                
                LottieWrapper.shared.stopLoading()
                
            case .failure:
                
                LottieWrapper.shared.stopLoading()
            }
        }
    }
}

extension ProfileViewController: UserInfoCellDelegate {
    
    func didTapFriend() {
        
        guard let friendsId = user?.friends else { return }
        
        let friendListVC = FriendListViewController(usersId: friendsId)
        
        navigationController?.pushViewController(friendListVC, animated: true)
    }
    
    func didTapLeftButton() {
        
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        ProfileSections.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        switch section {
            
        case ProfileSections.userInfo.rawValue:
            
            return 1
            
        case ProfileSections.choosePet.rawValue:
            
            return pets?.count ?? 0

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
            
            return setUserInfoCell(collectionView: collectionView, indexPath: indexPath)
            
        case ProfileSections.choosePet.rawValue:

            return setChoosePetCell(collectionView: collectionView, indexPath: indexPath)
            
        case ProfileSections.chooseContent.rawValue:
            
            return setChooseContentCell(collectionView: collectionView, indexPath: indexPath)
            
        case ProfileSections.postsPhoto.rawValue:
            
            return setPostPhotoCell(collectionView: collectionView, indexPath: indexPath)
            
        default:
            return UICollectionViewCell()
        }
    }
    
    private func setUserInfoCell(collectionView: UICollectionView,
                                 indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let infoCell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileInfoCell.identifier,
                                                                for: indexPath) as? ProfileInfoCell
        else {
            fatalError("Cannot dequeue ProfileInfoCell")
        }
        
        if let user = user {
            
            infoCell.configureCell(user: user, postCount: posts?.count ?? 0)
            
            infoCell.delegate = self
        }
        return infoCell
    }
    
    private func setChoosePetCell(collectionView: UICollectionView,
                                  indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let petCell = collectionView.dequeueReusableCell(withReuseIdentifier: PetItemCell.identifier,
                                                               for: indexPath) as? PetItemCell
        else {
            fatalError("Cannot dequeue PhotoItemCell")
        }
        
        guard let userPets = pets else { return petCell }
        
        let userPet = userPets[indexPath.item]
        
        if selectedPetIndex == nil {
            petCell.selectState = false
        }
        petCell.configureCell(pet: userPet)
        
        return petCell
    }
    
    private func setChooseContentCell(collectionView: UICollectionView,
                                      indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let chooseCell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentButtonCell.identifier,
                                                                  for: indexPath) as? ContentButtonCell
        else {
            fatalError("Cannot dequeue ContentButtonCell")
        }
        chooseCell.delegate = self
        
        return chooseCell
    }
    
    private func setPostPhotoCell(collectionView: UICollectionView,
                                  indexPath: IndexPath) -> UICollectionViewCell {
        
        if isPhoto {
            
            guard let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoItemCell.identifier,
                                                                     for: indexPath) as? PhotoItemCell
            else {
                fatalError("Cannot dequeue PhotoItemCell")
            }
            
            if let posts = displayPosts,
               let imageUrl = URL(string: posts[indexPath.item].photo) {
                
                photoCell.configureCell(photoURL: imageUrl)
            }
            
            return photoCell
            
        } else {
            
            guard let trackCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackHostoryCell.identifier,
                for: indexPath
            ) as? TrackHostoryCell
                    
            else {
                fatalError("Cannot dequeue TrackHostoryCell")
            }
            
            if let trackInfos = displayTrackInfos,
               let userPets = pets {
                
                let trackInfo = trackInfos[indexPath.item]
                
                for userPet in userPets where userPet.id == trackInfo.petId {
                    
                    trackCell.configureCell(pet: userPet, trackInfo: trackInfo)
                }
            }
            return trackCell
        }
    }
}

extension ProfileViewController: UICollectionViewDelegate {
    
    private func updateDisplayContent(isFilter: Bool, filterIndex: IndexPath) {
        
        guard let userPets = pets,
              let posts = posts,
              let trackInfos = trackInfos
        else {
            return
        }
        
        if isFilter {
            
            displayPosts = posts.filter { $0.petId == userPets[filterIndex.item].id }
            
            displayTrackInfos = trackInfos.filter { $0.petId == userPets[filterIndex.item].id }
            
            selectedPetIndex = filterIndex
            
        } else {
            
            displayPosts = posts
            
            displayTrackInfos = trackInfos
            
            selectedPetIndex = nil
        }
    }
    
    private func updateCellSelectState(cell: PetItemCell,
                                       collectionView: UICollectionView,
                                       indexPath: IndexPath,
                                       selectedPetIndex: IndexPath?) {
        
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
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == ProfileSections.choosePet.rawValue {
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? PetItemCell
            else {
                return
            }
            updateCellSelectState(cell: cell,
                                  collectionView: collectionView,
                                  indexPath: indexPath,
                                  selectedPetIndex: selectedPetIndex)
            
            updateDisplayContent(isFilter: cell.selectState, filterIndex: indexPath)
            
        } else if indexPath.section == ProfileSections.postsPhoto.rawValue {
            
            if isPhoto {
                
                guard let user = user,
                      let post = displayPosts?[indexPath.item]
                else { return }
                
                let photoPostVC = PhotoPostViewController(user: user, post: post)
                
                navigationController?.pushViewController(photoPostVC, animated: true)
                
            } else {
                
                guard let trackInfos = displayTrackInfos,
                        let userPets = pets else {
                    return
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
