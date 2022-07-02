//
//  PhotoPostViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/22.
//

import UIKit
import FirebaseFirestore

class PhotoPostViewController: UIViewController {
    
    private let postManager = PostManager.shared
    
    private let userManager = UserManager.shared
    
    private let petManager = PetManager.shared
    
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
    
    private var isLike = false {
        
        didSet {
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    private var userComments: [UserComment] = [] {
        didSet {
            
            userComments.sort { $0.comment.createdTime.dateValue() > $1.comment.createdTime.dateValue() }
            
            tableView.reloadSections(IndexSet(integer: 1), with: .fade)
        }
    }
    
    private var comments: [Comment]?
    
    private let userImageView = UIImageView()
    
    let userInputTextView = InputTextView()
    
    let sendButton = UIButton()
    
    let inputBackView = UIView()
    
    let inputSeperatorLine = UIView()
    
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
        
        getPostUser()
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        tabBarController?.tabBar.isHidden = false
    }
    
    func setup() {
        
        listenPostUpdate()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(PhotoPostCell.self,
                           forCellReuseIdentifier: PhotoPostCell.identifier)
        
        tableView.register(CommentCell.self,
                           forCellReuseIdentifier: CommentCell.identifier)
        
        userInputTextView.isScrollEnabled = false
        userInputTextView.placeholder = "Enter Comment"
        userInputTextView.delegate = self
        
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
    }
    
    func style() {
        
        navigationController?.navigationBar.tintColor = .Orange1
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        navigationItem.title = "Post"
        
        view.backgroundColor = .white
        
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
    
        inputSeperatorLine.backgroundColor = .lightGray
        
        let imageUrl = URL(string: user.userImage)
        userImageView.kf.setImage(with: imageUrl)
        userImageView.contentMode = .scaleAspectFill
        
        userInputTextView.backgroundColor = .white
        userInputTextView.font = UIFont.systemFont(ofSize: 18)
        
        sendButton.layer.cornerRadius = 3
        sendButton.setTitle("Submit", for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        sendButtonDisable()
        
        inputBackView.backgroundColor = .white
    }
    
    func layout() {
        
        view.addSubview(tableView)
        view.addSubview(inputBackView)
        view.addSubview(inputSeperatorLine)
        inputBackView.addSubview(userImageView)
        inputBackView.addSubview(userInputTextView)
        inputBackView.addSubview(sendButton)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         leading: view.leadingAnchor,
                         bottom: inputBackView.topAnchor,
                         trailing: view.trailingAnchor,
                         padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        userImageView.anchor(top: inputBackView.topAnchor,
                             leading: inputBackView.leadingAnchor,
                             width: 40,
                             height: 40,
                             padding: UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 0))
        
        userInputTextView.anchor(top: inputBackView.topAnchor,
                                 leading: userImageView.trailingAnchor,
                                 bottom: inputBackView.bottomAnchor,
                                  trailing: sendButton.leadingAnchor,
                                 padding: UIEdgeInsets(top: 8, left: 10, bottom: 10, right: 10))
        
        sendButton.anchor(trailing: inputBackView.trailingAnchor,
                          centerY: inputBackView.centerYAnchor,
                          width: 60,
                          height: 35,
                          padding: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 20))
        
        inputBackView.anchor(leading: view.leadingAnchor,
                             bottom: view.safeAreaLayoutGuide.bottomAnchor,
                             trailing: view.trailingAnchor)
        
        inputSeperatorLine.anchor(leading: inputBackView.leadingAnchor,
                                  bottom: inputBackView.topAnchor,
                                  trailing: inputBackView.trailingAnchor,
                                  height: 0.5)
        
        inputBackView.layoutIfNeeded()
        userImageView.makeRound()
        userImageView.clipsToBounds = true
    }
    
    func listenPostUpdate() {
        
        postManager.listenPost(postId: post.id) { [weak self] result in
            
            switch result {
                
            case .success(let post):
                
                self?.post = post
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func getPostUser() {
        
        userManager.fetchUserInfo(userId: post.userId) { [weak self] result in
            
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
    
    func getPet(otherUserId: String) {
        
        petManager.fetchPetInfo(userId: otherUserId, petId: post.petId) { [weak self] result in
            
            switch result {
                
            case .success(let pet):
                
                self?.pet = pet
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func getComments() {
        
        postManager.listenComments(postId: post.id) { [weak self] result in
            
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
    
    func getUserInfo(userId: String, comment: Comment) {
        
        userManager.fetchUserInfo(userId: userId) { [weak self] result in
            
            switch result {
                
            case .success(let user):
                
                let userComment = UserComment(user: user, comment: comment)
                
                self?.userComments.append(userComment)
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    @objc func didTapSendButton() {
        
        sendButtonDisable()
        
        guard let text = userInputTextView.text,
              userInputTextView.text != "" else {
            return
        }
        
        var comment = Comment(id: "",
                              postId: post.id,
                              senderId: user.id,
                              text: text,
                              createdTime: Timestamp(date: Date()))
        
        postManager.setupComment(comment: &comment) { [weak self] result in
            
            switch result {
                
            case .success:
                
//                guard let user = self?.user else { return }
                
//                self?.comments?.append(comment)
                
//                let userComment = UserComment(user: user, comment: comment)
//                self?.userComments.append(userComment)
                
//                let indexPath = IndexPath(row: commentCount, section: 1)
//
//                self?.tableView.insertRows(at: [indexPath], with: .automatic)
//
//                self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                
                self?.userInputTextView.text = ""
                
                self?.userInputTextView.showPlaceholderLabel()
                
            case .failure(let error):
                
                print(error)
            }
        }
        
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
        }
    }
    
    func checkIsLike() {
        
        let userId = user.id
        
        if post.likesId.contains(userId) {
            
            isLike = true
        } else {
            
            isLike = false
        }
    }
    
//    @objc func textFieldDidChange(_ textField: UITextField) {
//        guard textField == userInputTextfield else { return }
//
//        if textField.text != "" {
//            sendButton.isEnabled = true
//        } else {
//            sendButton.isEnabled = false
//        }
//    }
    
    func sendButtonEnable() {
        
        sendButton.isEnabled = true
        sendButton.backgroundColor = .Orange1
    }
    
    func sendButtonDisable() {
        
        sendButton.isEnabled = false
        sendButton.backgroundColor = .Gray1
    }
}

extension PhotoPostViewController: PhotoItemCellDelegate {
    
    func didTapLike(for cell: PhotoPostCell, like: Bool) {
        
        if like {
            
            likeCount += 1
            
            postManager.addPostLike(postId: post.id, userId: user.id)
            
        } else {
            
            likeCount -= 1
            
            postManager.removePostLike(postId: post.id, userId: user.id)
        }
        
        isLike = like
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
            
            commentCell.configureCell(userPhoto: userComment.user.userImage,
                                      userName: userComment.user.name,
                                      comment: userComment.comment)
            
            return commentCell
            
        default:
            return UITableViewCell()
        }
    }
}

extension PhotoPostViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView == userInputTextView else { return }
        
        if textView.text.isEmpty {
            
            sendButtonDisable()
        } else {
            
            sendButtonEnable()
        }
    }
}
