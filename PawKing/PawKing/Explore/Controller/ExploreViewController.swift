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
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout.exploreViewCompositionalLayout()
    )
    
    private var user: User?
    
    private var allPosts: [Post]?
    
    private var friendPosts: [Post]?
    
    private var displayPosts: [Post]? {
        didSet {
            collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    private let refreshControl = UIRefreshControl()
    
    private let allModeButton = UIButton()
    
    private let friendModeButton = UIButton()
    
    private let buttonIndicatorView = UIView()
    
    private let buttonBackView = UIView()
    
    private let noPostLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        style()
        layout()
    }
    
    override func viewDidLayoutSubviews() {
        
        if friendModeButton.isSelected {
            
            buttonIndicatorView.center.x = friendModeButton.center.x
            
        } else {
            
            buttonIndicatorView.center.x = allModeButton.center.x
        }
    }
    
    private func setup() {
        
        navigationController?.navigationBar.tintColor = .white
        
        LottieWrapper.shared.startLoading()
        
        getAllPosts()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getAllPosts),
                                               name: .updateUser,
                                               object: nil)
        
        view.backgroundColor = .BattleGrey
        
        navigationItem.title = "Explore"
            
        navigationItem.searchController = searchController
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: PhotoItemCell.identifier)
        
        refreshControl.addTarget(self, action: #selector(getAllPosts), for: .valueChanged)
        
        setSearchController()
        
        allModeButton.addTarget(self, action: #selector(didTapAll), for: .touchUpInside)
        friendModeButton.addTarget(self, action: #selector(didTapFriend), for: .touchUpInside)
        
        noPostLabel.text = "No Post"
        noPostLabel.isHidden = true
    }
    
    private func style() {
        
        allModeButton.setTitle("All", for: .normal)
        allModeButton.setTitleColor(.MainGray, for: .normal)
        allModeButton.setTitleColor(.CoralOrange, for: .selected)
        allModeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        friendModeButton.setTitle("Friends", for: .normal)
        friendModeButton.setTitleColor(.MainGray, for: .normal)
        friendModeButton.setTitleColor(.CoralOrange, for: .selected)
        friendModeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        buttonIndicatorView.backgroundColor = .CoralOrange
        
        buttonBackView.backgroundColor = .white
        buttonBackView.layer.cornerRadius = 20
        buttonBackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        noPostLabel.textColor = .BattleGreyLight
        noPostLabel.textAlignment = .center
        noPostLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
    }
    
    private func layout() {
        
        view.addSubview(collectionView)
        collectionView.addSubview(refreshControl)
        
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
                          padding: UIEdgeInsets(top: 7, left: 0, bottom: 0, right: 0))
        
        buttonIndicatorView.anchor(top: allModeButton.bottomAnchor,
                                   centerX: allModeButton.centerXAnchor,
                                   width: 10,
                                   height: 10,
                                   padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        collectionView.anchor(top: hStackView.bottomAnchor,
                              leading: view.leadingAnchor,
                              bottom: view.safeAreaLayoutGuide.bottomAnchor,
                              trailing: view.trailingAnchor,
                              padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        
        buttonIndicatorView.layer.cornerRadius = 5
        
        collectionView.addSubview(noPostLabel)
        
        noPostLabel.anchor(centerY: collectionView.centerYAnchor,
                           centerX: collectionView.centerXAnchor)
    }
    
    @objc private func getAllPosts() {
        
        user = UserManager.shared.currentUser
        
        guard let blockIds = user?.blockUsersId else { return }
        
        PostManager.shared.fetchAllPosts(blockIds: blockIds) { [weak self] result in
            
            switch result {
                
            case .success(let posts):
                
                self?.refreshControl.endRefreshing()
                
                self?.allPosts = posts
                
                if self?.friendModeButton.isSelected ?? true {

                    self?.didTapFriend()

                } else {
                    
                    self?.didTapAll()
                }
                
                self?.getFriendPosts()
                
                LottieWrapper.shared.stopLoading()
                
            case .failure(let error):
                
                self?.refreshControl.endRefreshing()
                
                LottieWrapper.shared.stopLoading()
                
                LottieWrapper.shared.showError(error: error)
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
    
    @objc private func getFriendPosts() {
        
        guard let user = UserManager.shared.currentUser,
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
        
        self.noPostLabel.isHidden = true
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.buttonIndicatorView.center.x = self.allModeButton.center.x
        })
    }
    
    @objc func didTapFriend() {
        
        displayPosts = friendPosts
        
        allModeButton.isSelected = false
        friendModeButton.isSelected = true
        
        if self.friendPosts?.count == 0 {
            
            self.noPostLabel.isHidden = false
        } else {
            
            self.noPostLabel.isHidden = true
        }
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.buttonIndicatorView.center.x = self.friendModeButton.center.x
        })
    }
}

extension ExploreViewController: ResultViewControllerDelegate {
    
    func didSelectResultUser(theOtherUser: User) {
        
        let userPhotoVC = UserPhotoWallViewController(otherUserId: theOtherUser.id)
                    
        navigationController?.pushViewController(userPhotoVC, animated: true)
    }
}

extension ExploreViewController: UICollectionViewDataSource {
    
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
        
        cell.imageView.image = UIImage.asset(.Image_Placeholder_Paw)
        
        guard let posts = displayPosts,
              let imageUrl = URL(string: posts[indexPath.item].photo)
        else {
            return cell
        }
        
        cell.configureCell(photoURL: imageUrl)
        
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
