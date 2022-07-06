//
//  ExploreViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/14.
//

import UIKit
import FirebaseAuth

class ExploreViewController: UIViewController {
    
    var searchController: UISearchController?
    
    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: configureLayout())

    private let postManager = PostManager.shared
    
    private let userManager = UserManager.shared
    
    private var user: User?
    
    private var allPosts: [Post]?
    
    private var friendPosts: [Post]?
    
    private var displayPosts: [Post]? {
        didSet {
            collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    let allModeButton = UIButton()
    
    let friendModeButton = UIButton()
    
    let buttonIndicatorView = UIView()
    
    let buttonBackView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        style()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let user = UserManager.shared.currentUser {
            
            self.user = user
            
            getAllPosts(without: user.blockUsersId)
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        if friendModeButton.isSelected {
            
            buttonIndicatorView.center.x = friendModeButton.center.x
            
        } else {
            
            buttonIndicatorView.center.x = allModeButton.center.x
        }
    }
    
    private func setup() {
        
        view.backgroundColor = .BattleGrey
        
        navigationItem.title = "Explore"
            
        navigationItem.searchController = searchController

        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: PhotoItemCell.identifier)
        
        setSearchController()
        
        allModeButton.addTarget(self, action: #selector(didTapAll), for: .touchUpInside)
        friendModeButton.addTarget(self, action: #selector(didTapFriend), for: .touchUpInside)
    }
    
    private func style() {
        
        allModeButton.setTitle("All", for: .normal)
        allModeButton.setTitleColor(.Gray1, for: .normal)
        allModeButton.setTitleColor(.white, for: .selected)
        allModeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        friendModeButton.setTitle("Friends", for: .normal)
        friendModeButton.setTitleColor(.Gray1, for: .normal)
        friendModeButton.setTitleColor(.white, for: .selected)
        friendModeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        buttonIndicatorView.backgroundColor = .Orange1
        
        buttonBackView.backgroundColor = .white
        buttonBackView.layer.cornerRadius = 20
        buttonBackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func layout() {
        
        view.addSubview(collectionView)
        
        let hStackView = UIStackView(arrangedSubviews: [allModeButton, friendModeButton])
        hStackView.distribution = .fillEqually
        view.addSubview(buttonBackView)
        view.addSubview(buttonIndicatorView)
        view.addSubview(hStackView)
        
        buttonBackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                              leading: view.leadingAnchor,
                              bottom: collectionView.topAnchor,
                              trailing: view.trailingAnchor)
        
        hStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                          leading: view.leadingAnchor,
                          trailing: view.trailingAnchor,
                          height: 30,
                          padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0))
        
        buttonIndicatorView.anchor(centerY: allModeButton.centerYAnchor,
                          centerX: allModeButton.centerXAnchor,
                          width: 100,
                          height: 30)
        
        collectionView.anchor(top: hStackView.bottomAnchor,
                              leading: view.leadingAnchor,
                              bottom: view.bottomAnchor,
                              trailing: view.trailingAnchor,
                              padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0))
        
        buttonIndicatorView.layer.cornerRadius = 5
    }
    
    private func getAllPosts(without blockIds: [String]) {
        
        postManager.fetchAllPosts(blockIds: blockIds) { [weak self] result in
            
            switch result {
                
            case .success(let posts):
                
                self?.allPosts = posts
                
                if self?.friendModeButton.isSelected ?? true {

                    self?.didTapFriend()

                } else {
                    
                    self?.didTapAll()
                }
                
                self?.getFriendPosts()
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    private func setSearchController() {
        
        let resultViewController = ResultViewController()
        
        resultViewController.resultVCDelegate = self
        
        let navResultVC = UINavigationController(rootViewController: resultViewController)
        
        searchController = UISearchController(
            searchResultsController: navResultVC
        )
        searchController?.searchResultsUpdater = resultViewController
        
        searchController?.searchBar.searchTextField.leftView?.tintColor = .LightGray
        searchController?.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search User",
            attributes: [.foregroundColor: UIColor.lightGray])

        navigationItem.searchController = searchController
        
        definesPresentationContext = true
    }
    
    private func getFriendPosts() {
        
        guard let user = user,
              let posts = allPosts else { return }
        
        var friendPosts: [Post] = []
        
        for post in posts where user.friends.contains(post.userId) {
            
            friendPosts.append(post)
        }
        
        self.friendPosts = friendPosts
    }
    
    @objc func didTapAll() {
        
        displayPosts = allPosts
        
        allModeButton.isSelected = true
        friendModeButton.isSelected = false
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.buttonIndicatorView.center.x = self.allModeButton.center.x
        })
    }
    
    @objc func didTapFriend() {
        
        displayPosts = friendPosts
        
        allModeButton.isSelected = false
        friendModeButton.isSelected = true
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.buttonIndicatorView.center.x = self.friendModeButton.center.x
        })
    }
}

extension ExploreViewController: ResultViewControllerDelegate {
    
    func didSelectResultUser(theOtherUser: User) {
        
        let userPhotoVC = UserPhotoWallViewController(otherUser: theOtherUser)
                    
        navigationController?.pushViewController(userPhotoVC, animated: true)
    }
}

extension ExploreViewController: UICollectionViewDataSource {
    
    private static func configureLayout() -> UICollectionViewLayout {
        
        let contentInset: CGFloat = 1
        
        // Full
        let fullItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalWidth(1))
        let fullItem = NSCollectionLayoutItem(layoutSize: fullItemSize)

        fullItem.contentInsets = NSDirectionalEdgeInsets(top: contentInset,
                                                         leading: contentInset,
                                                         bottom: contentInset,
                                                         trailing: contentInset)

        let fullGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalWidth(2/3))

        let fullGroup = NSCollectionLayoutGroup.vertical(layoutSize: fullGroupSize,
                                                             subitem: fullItem, count: 1)

        // Main with pair
        let mainItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(2/3),
                                                  heightDimension: .fractionalHeight(1))
        let mainItem = NSCollectionLayoutItem(layoutSize: mainItemSize)

        mainItem.contentInsets = NSDirectionalEdgeInsets(top: contentInset,
                                                         leading: contentInset,
                                                         bottom: contentInset,
                                                         trailing: contentInset)

        let pairItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1/2))
        let pairItem = NSCollectionLayoutItem(layoutSize: pairItemSize)

        pairItem.contentInsets = NSDirectionalEdgeInsets(top: contentInset,
                                                         leading: contentInset,
                                                         bottom: contentInset,
                                                         trailing: contentInset)

        let trailingGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
                                                   heightDimension: .fractionalHeight(1))
        let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: trailingGroupSize,
                                                             subitem: pairItem,
                                                             count: 2)

        let mainWithPairGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                           heightDimension: .fractionalWidth(4/9))

        let mainWithPairGroup = NSCollectionLayoutGroup.horizontal(layoutSize: mainWithPairGroupSize,
                                                                 subitems: [mainItem, trailingGroup])

        // Triplet
        let tripletItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
                                                heightDimension: .fractionalHeight(1))
        let tripletItem = NSCollectionLayoutItem(layoutSize: tripletItemSize)

        tripletItem.contentInsets = NSDirectionalEdgeInsets(top: contentInset,
                                                            leading: contentInset,
                                                            bottom: contentInset,
                                                            trailing: contentInset)

        let tripletGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                           heightDimension: .fractionalWidth(2/9))

        let tripletGroup = NSCollectionLayoutGroup.horizontal(layoutSize: tripletGroupSize,
                                                              subitems: [tripletItem, tripletItem, tripletItem])

        // Reversed main with pair
        let mainWithRevGroup = NSCollectionLayoutGroup.horizontal(layoutSize: mainWithPairGroupSize,
                                                                subitems: [trailingGroup, mainItem])

        let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                           heightDimension: .fractionalWidth(16/9))

        let nestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: nestedGroupSize,
                                                             subitems: [fullGroup,
                                                                        mainWithPairGroup,
                                                                        tripletGroup,
                                                                        mainWithRevGroup])

        let section = NSCollectionLayoutSection(group: nestedGroup)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        displayPosts?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoItemCell.identifier,
                                                                for: indexPath) as? PhotoItemCell
        else {
            fatalError("Cannot dequeue PhotoItemCell")
        }
        
        cell.imageView.image = UIImage.asset(.Image_Placeholder)
        
        guard let posts = displayPosts else { return cell }
        
        let imageUrl = URL(string: posts[indexPath.item].photo)
        
        cell.imageView.kf.setImage(with: imageUrl)
        
        return cell
    }
}

extension ExploreViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard Auth.auth().currentUser != nil else {
            
            NotificationCenter.default.post(name: .showSignInView, object: .none)
            return
        }
        
        guard let user = user,
              let post = displayPosts?[indexPath.item]
        else { return }

        let photoPostVC = PhotoPostViewController(user: user, post: post)

        navigationController?.pushViewController(photoPostVC, animated: true)
    }
}
