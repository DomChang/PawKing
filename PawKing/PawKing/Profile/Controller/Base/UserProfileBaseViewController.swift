//
//  UserBaseViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/27.
//

import UIKit

class UserProfileBaseViewController: UIViewController {
    
    var collectionView: UICollectionView!
    
    let userManager = UserManager.shared
    
    let postManager = PostManager.shared
    
   let lottie = LottieWrapper.shared
    
    var isPhoto = true {
        didSet {
            collectionView.reloadSections(IndexSet(integer: collectionView.numberOfSections - 1))
            checkIsEmpty()
        }
    }
    
    var user: User?
    
    var pets: [Pet]? {
        didSet {
            collectionView.reloadSections(IndexSet(integer: 1))
        }
    }
    
    var posts: [Post]? {
        didSet {
            collectionView.reloadSections(IndexSet(integer: collectionView.numberOfSections - 1))
            collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
        }
    }
    
    var displayPosts: [Post]? {
        didSet {
            collectionView.reloadSections(IndexSet(integer: collectionView.numberOfSections - 1))
            checkIsEmpty()
        }
    }
    
    var trackInfos: [TrackInfo]? {
        didSet {
            collectionView.reloadSections(IndexSet(integer: collectionView.numberOfSections - 1))
        }
    }
    
    var displayTrackInfos: [TrackInfo]? {
        didSet {
            collectionView.reloadSections(IndexSet(integer: collectionView.numberOfSections - 1))
            checkIsEmpty()
        }
    }
    
    var selectedPetIndex: IndexPath?
    
    let emptyLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        style()
        layout()
        
    }

    func setup() {

        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        collectionView.allowsSelection = true
        collectionView.isUserInteractionEnabled = true
        
        collectionView.register(ProfileInfoCell.self,
                                forCellWithReuseIdentifier: ProfileInfoCell.identifier)
        
        collectionView.register(OtherUserInfoCell.self,
                                forCellWithReuseIdentifier: OtherUserInfoCell.identifier)
        
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
        
        emptyLabel.isHidden = true
    }
    
    func style() {
        
        navigationController?.navigationBar.tintColor = .white
        
        view.backgroundColor = .BattleGrey
        
        collectionView.backgroundColor = .white
        
        emptyLabel.textColor = .BattleGreyLight
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
    }
    
    func layout() {
        
        view.addSubview(collectionView)
        collectionView.addSubview(emptyLabel)
        
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                               leading: view.leadingAnchor,
                               bottom: view.bottomAnchor,
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
    
    func fetchPet(by user: User) {
        
        userManager.fetchPets(userId: user.id) { [weak self] result in
            
            switch result {
                
            case .success(let pets):
                
                self?.pets = pets
                
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
