//
//  ExploreViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/14.
//

import UIKit

class ExploreViewController: UIViewController {
    
    var searchController: UISearchController?
    
    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: configureLayout())

    private let postManager = PostManager.shared
    
    private let userManager = UserManager.shared
    
    private let user: User
    
    private var allPosts: [Post]?
    
    private var friendPosts: [Post]?
    
    private var displayPosts: [Post]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    init(user: User) {
        
        self.user = user
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        getAllPosts()
    }
    
    private func setup() {
        
        view.backgroundColor = .white
        
        navigationItem.title = "Explore"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.largeTitleDisplayMode = .automatic
        
        navigationItem.searchController = searchController
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(ModeChangeHeaderReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ModeChangeHeaderReusableView.identifier)
        
        collectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: PhotoItemCell.identifier)
        
        setSearchController()
    }
    
    private func style() {
        
    }
    
    private func layout() {
        
        view.addSubview(collectionView)
        
        collectionView.fillSafeLayout()
    }
    
    private func getAllPosts() {
        
        postManager.fetchAllPosts { [weak self] result in
            
            switch result {
                
            case .success(let posts):
                
                self?.allPosts = posts
                
                self?.displayPosts = posts
                
                self?.getFriendPosts()
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    private func setSearchController() {
        
        let resultViewController = ResultViewController(user: user)
        
        searchController = UISearchController(
            searchResultsController: resultViewController
        )
        searchController?.searchResultsUpdater = resultViewController
        
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
    }
    
    private func getFriendPosts() {
        
        guard let posts = allPosts else { return }
        
        var friendPosts: [Post] = []
        
        for post in posts where user.friends.contains(post.userId) {
            
            friendPosts.append(post)
        }
        
        self.friendPosts = friendPosts
    }
}

extension ExploreViewController: ModeChangeHeaderDelegate {
    
    func didTapAll() {
        
        displayPosts = allPosts
    }
    
    func didTapFriend() {
        
        displayPosts = friendPosts
    }
}

extension ExploreViewController: UISearchResultsUpdating {
   func updateSearchResults(for searchController: UISearchController) {
    // TO-DO: Implement here
  }
}

extension ExploreViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                         withReuseIdentifier: ModeChangeHeaderReusableView.identifier,
                                                                               for: indexPath) as? ModeChangeHeaderReusableView else {
            fatalError("Cannot dequeue ModeChangeHeaderReusableView")
        }
        
        headerView.delegate = self
        
        return headerView
    }
    
    private static func configureLayout() -> UICollectionViewLayout {
        
        let contentInset: CGFloat = 2
        
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

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                  heightDimension: .absolute(50.0))
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        header.pinToVisibleBounds = true
        
        section.boundarySupplementaryItems = [header]
        
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
        
        guard let post = displayPosts?[indexPath.item]
        else { return }

        let photoPostVC = PhotoPostViewController(user: user, post: post)

        navigationController?.pushViewController(photoPostVC, animated: true)
    }
}
