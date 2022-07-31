//
//  PhotoPostViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/22.
//

import UIKit
import FirebaseFirestore
import Lottie

class PhotoPostViewController: UIViewController {
    
    private let tableView = UITableView()
    
    private let user: User
    
    private var postUser: User?
    
    private var post: Post {
        didSet {
            checkIsLike()
            likeCount = post.likesId.count
        }
    }
    
    private var pet: Pet? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var likeCount: Int {
        didSet {
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    private var isLike = false
    
    private var userComments: [UserComment] = [] {
        didSet {
            
            userComments.sort { $0.comment.createdTime.dateValue() > $1.comment.createdTime.dateValue() }
            tableView.reloadSections(IndexSet(integer: 1), with: .fade)
        }
    }
    
    private var comments: [Comment]?
    
    private var likingView: AnimationView?
  
    private let inputCommentView = InputCommentView()
    
    private let alertHelper = AlertHelper()
    
    init(user: User, post: Post) {
        
        self.user = user
        
        self.post = post
        
        self.likeCount = post.likesId.count

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
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setup() {
        
        getPostUser()
        
        listenPostUpdate()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PhotoPostCell.self,
                           forCellReuseIdentifier: PhotoPostCell.identifier)
        tableView.register(CommentCell.self,
                           forCellReuseIdentifier: CommentCell.identifier)
        
        inputCommentView.sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
    }
    
    private func style() {
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        navigationItem.title = "Post"
        
        view.backgroundColor = .white
        
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        
        let imageUrl = URL(string: user.userImage)
        inputCommentView.userImageView.kf.setImage(with: imageUrl)
    }
    
    private func layout() {
        
        view.addSubview(tableView)
        view.addSubview(inputCommentView)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         leading: view.leadingAnchor,
                         bottom: inputCommentView.topAnchor,
                         trailing: view.trailingAnchor,
                         padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))

        inputCommentView.anchor(leading: view.leadingAnchor,
                             bottom: view.safeAreaLayoutGuide.bottomAnchor,
                             trailing: view.trailingAnchor)
        
        // Change bottom bounce area backgroud color
        tableView.layoutIfNeeded()
        let topView = UIView(frame: CGRect(x: 0, y: -tableView.bounds.height,
                width: tableView.bounds.width, height: tableView.bounds.height))
        topView.backgroundColor = .BattleGrey
        tableView.addSubview(topView)
    }
    
    private func listenPostUpdate() {
        
        PostManager.shared.listenPost(postId: post.id) { [weak self] result in
            
            switch result {
                
            case .success(let post):
                
                self?.post = post
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    private func getPostUser() {
        
        UserManager.shared.fetchUserInfo(userId: post.userId) { [weak self] result in
            
            switch result {
                
            case .success(let otherUser):
                
                self?.postUser = otherUser
                
                self?.getPet(otherUserId: otherUser.id)
                
                self?.getComments()
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    private func getPet(otherUserId: String) {
        
        PetManager.shared.fetchPetInfo(userId: otherUserId, petId: post.petId) { [weak self] result in
            
            switch result {
                
            case .success(let pet):
                
                self?.pet = pet
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    private func getComments() {
        
        PostManager.shared.listenComments(postId: post.id, blockIds: user.blockUsersId) { [weak self] result in
            
            switch result {
                
            case .success(let comments):
                
                self?.comments = comments
                
                for comment in comments {
                    
                    self?.getUserInfo(userId: comment.senderId, comment: comment)
                }
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    private func getUserInfo(userId: String, comment: Comment) {
        
        UserManager.shared.fetchUserInfo(userId: userId) { [weak self] result in
            
            switch result {
                
            case .success(let user):
                
                let userComment = UserComment(user: user, comment: comment)
                
                if userComment.user.id != "unknown" {
                    self?.userComments.append(userComment)
                }
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    @objc private func didTapSendButton() {
        
        LottieWrapper.shared.startLoading()
        
        inputCommentView.sendButtonDisable()
        
        guard let text = inputCommentView.userInputTextView.text,
              inputCommentView.userInputTextView.text != "" else {
            return
        }
        
        var comment = Comment(id: "",
                              postId: post.id,
                              senderId: user.id,
                              text: text,
                              createdTime: Timestamp(date: Date()))
        
        PostManager.shared.setupComment(comment: &comment) { [weak self] result in
            
            switch result {
                
            case .success:
                
                LottieWrapper.shared.stopLoading()
                
                self?.inputCommentView.userInputTextView.text = ""
                
                self?.inputCommentView.userInputTextView.showPlaceholderLabel()
                
            case .failure(let error):
                
                LottieWrapper.shared.stopLoading()
                LottieWrapper.shared.showError(error: error)
            }
        }
        
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
        }
    }
    
    private func checkIsLike() {
        
        let userId = user.id
        
        if post.likesId.contains(userId) {
            
            isLike = true
        } else {
            
            isLike = false
        }
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
    
    private func setDeleteAction() {
        
        LottieWrapper.shared.startLoading()
        
        PostManager.shared.deletePost(post: post) { result in
            switch result {
                
            case .success:
                
                LottieWrapper.shared.stopLoading()
                
                NotificationCenter.default.post(name: .updateUser, object: .none)
                
                self.navigationController?.popViewController(animated: true)
                
            case .failure(let error):
                
                LottieWrapper.shared.stopLoading()
                
                LottieWrapper.shared.showError(error: error)
            }
        }
    }
    
    private func setBlockAction(postUser: User) {
        
        LottieWrapper.shared.startLoading()
        
        UserManager.shared.addBlockUser(userId: user.id, blockId: postUser.id) { result in
            
            switch result {
                
            case.success:
                
                LottieWrapper.shared.stopLoading()
                
                self.navigationController?.popViewController(animated: true)
                
            case .failure(let error):
                
                LottieWrapper.shared.stopLoading()
                
                LottieWrapper.shared.showError(error: error)
            }
        }
    }
    
    private func showActionSheet() {
        
        guard let postUser = postUser else { return }
        
        if self.user.id == postUser.id {
            
            alertHelper.showActionSheet(title: nil, message: nil,
                                        actionName: "Delete Post",
                                        actionStyle: .destructive,
                                        action: { self.setDeleteAction() },
                                        by: self)
        } else {
            alertHelper.showActionSheet(title: nil, message: nil,
                                        actionName: "Block and Report User",
                                        actionStyle: .destructive,
                                        action: { self.setBlockAction(postUser: postUser) },
                                        by: self)
        }
    }
}

extension PhotoPostViewController: PhotoPostCellDelegate {
    
    func didTapAction() {
        showActionSheet()
    }
    
    func didTapLike(for cell: PhotoPostCell, like: Bool) {
        
        if like {
            
            likeCount += 1
            
            PostManager.shared.addPostLike(postId: post.id, userId: user.id)
            
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        } else {
            
            likeCount -= 1
            
            PostManager.shared.removePostLike(postId: post.id, userId: user.id)
        }
        isLike = like
        
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        
        if isLike {
            
            LottieWrapper.shared.showLikeAnimation(addTo: tableView, cell: cell)
        }
    }
    
    func didTapUser() {
        
        guard let postUser = postUser else {
            return
        }
        if self.user.id != postUser.id {
            
            let postUserVC = UserPhotoWallViewController(otherUserId: postUser.id)
            navigationController?.pushViewController(postUserVC, animated: true)
        }
    }
    
    func didTapLikeUsers() {
        
        let likeUserVC = LikeUserListViewController(usersId: post.likesId, postId: post.id)
        navigationController?.pushViewController(likeUserVC, animated: true)
    }
}

extension PhotoPostViewController: CommentCellDelegate {
    
    func didTapCommentUser(from cell: CommentCell) {
        
        guard let otherUserId = cell.userId,
                cell.userId != user.id
        else {
            return
        }
        let commentUserVC = UserPhotoWallViewController(otherUserId: otherUserId)
        
        navigationController?.pushViewController(commentUserVC, animated: true)
    }
}

extension PhotoPostViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
            
        } else {
            return userComments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {

        case 0:
            
            guard let contentCell = tableView.dequeueReusableCell(withIdentifier: PhotoPostCell.identifier,
                                                                  for: indexPath) as? PhotoPostCell else {
                fatalError("Cannot dequeue PhotoPostCell")
            }
            
            guard let pet = pet,
                    let user = postUser else { return contentCell }
            
            contentCell.delegate = self
            contentCell.configureCell(user: user,
                                      pet: pet,
                                      post: post,
                                      likeCount: likeCount,
                                      isLike: isLike)
            contentCell.selectionStyle = .none
            
            return contentCell
            
        case 1:
            
            guard let commentCell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier,
                                                                  for: indexPath) as? CommentCell else {
                fatalError("Cannot dequeue CommentCell")
            }
            
            guard !userComments.isEmpty else {
                return commentCell
            }
            
            let userComment = userComments[indexPath.row]
            
            commentCell.configureCell(user: userComment.user,
                                      comment: userComment.comment)
            commentCell.delegate = self
            
            return commentCell
            
        default:
            return UITableViewCell()
        }
    }
}
