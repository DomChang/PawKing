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
    
    private let post: Post
    
    private var pet: Pet? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var commentSenders: [User] = []
    
    private var comments: [Comment]?
    
    let userInputTextfield = UITextField()
    
    let sentButton = UIButton()
    
    let inputBackView = UIView()
    
    private var userInputTopAnchor: NSLayoutConstraint!
    
    init(user: User, post: Post) {
        
        self.user = user
        
        self.post = post
        
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
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        tabBarController?.tabBar.isHidden = false
    }
    
    func setup() {
        
        getPet()
        
        getComments()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(PhotoPostCell.self,
                           forCellReuseIdentifier: PhotoPostCell.identifier)
        
        tableView.register(CommentCell.self,
                           forCellReuseIdentifier: CommentCell.identifier)
        
        userInputTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)),
                                  for: .editingChanged)
        
        sentButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
    }
    
    func style() {
        
        view.backgroundColor = .white
        
        tableView.backgroundColor = .white
        
        sentButton.isEnabled = false
        
        userInputTextfield.backgroundColor = .white
        userInputTextfield.layer.cornerRadius = 3
        userInputTextfield.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        userInputTextfield.layer.borderWidth = 0.8
        userInputTextfield.font = UIFont.systemFont(ofSize: 18)
        
        sentButton.layer.cornerRadius = 3
        sentButton.setTitle("發送", for: .normal)
        sentButton.backgroundColor = .O1
        
        inputBackView.layer.borderWidth = 0.8
        inputBackView.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        inputBackView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
    }
    
    func layout() {
        
        view.addSubview(tableView)
        view.addSubview(inputBackView)
        view.addSubview(userInputTextfield)
        view.addSubview(sentButton)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         leading: view.leadingAnchor,
                         bottom: inputBackView.topAnchor,
                         trailing: view.trailingAnchor,
                         padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        userInputTextfield.anchor(leading: view.leadingAnchor,
                                 bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                  trailing: sentButton.leadingAnchor,
                                  height: 36,
                                 padding: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 10))
        
        sentButton.anchor(trailing: view.trailingAnchor,
                          centerY: userInputTextfield.centerYAnchor,
                          width: 60,
                          height: 35,
                          padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20))
        
        inputBackView.anchor(leading: view.leadingAnchor,
                             trailing: view.trailingAnchor,
                             centerY: userInputTextfield.centerYAnchor,
                             height: 71)
        
        userInputTopAnchor =  userInputTextfield.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -52)
        userInputTopAnchor.isActive = true
    }
    
    func getPet() {
        
        petManager.fetchPetInfo(userId: user.id, petId: post.petId) { [weak self] result in
            
            switch result {
                
            case .success(let pet):
                
                self?.pet = pet
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func getComments() {
        
        postManager.fetchComments(postId: post.id) { [weak self] result in
            
            switch result {
                
            case .success(let comments):
                
                self?.comments = comments
                
                for comment in comments {
                    
                    self?.getUserInfo(userId: comment.senderId)
                }
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func getUserInfo(userId: String) {
        
        userManager.fetchUserInfo(userId: userId) { [weak self] result in
            
            switch result {
                
            case .success(let commentSenders):
                
                self?.commentSenders.append(commentSenders)
                
                self?.tableView.reloadData()
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    @objc func didTapSendButton() {
        
        sentButton.isEnabled = false
        
        guard let text = userInputTextfield.text,
              userInputTextfield.text != "" else {
            return
        }
        
        var comment = Comment(id: "",
                              postId: post.id,
                              senderId: post.userId,
                              text: text,
                              createdTime: Timestamp(date: Date()))
        
        postManager.setupComment(comment: &comment) { [weak self] result in
            
            switch result {
                
            case .success:
                
                guard let commentCount = self?.comments?.count,
                        let user = self?.user else { return }
                
                self?.comments?.append(comment)
                
                self?.commentSenders.append(user)
                
                let indexPath = IndexPath(row: commentCount, section: 1)
                
                self?.tableView.insertRows(at: [indexPath], with: .automatic)
                
                self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                
            case .failure(let error):
                
                print(error)
            }
        }
        
        userInputTextfield.text = ""
        
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard textField == userInputTextfield else { return }

        if textField.text != "" {
            sentButton.isEnabled = true
        } else {
            sentButton.isEnabled = false
        }
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
            
            return commentSenders.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {

        case 0:
            
            guard let contentCell = tableView.dequeueReusableCell(withIdentifier: PhotoPostCell.identifier,
                                                                  for: indexPath) as? PhotoPostCell else {
                fatalError("Cannot dequeue PhotoPostCell")
            }
            
            guard let pet = pet else { return contentCell }
            
            contentCell.configureCell(user: user, pet: pet, post: post)
            
            contentCell.selectionStyle = .none
            
            return contentCell
            
        case 1:
            
            guard let commentCell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier,
                                                                  for: indexPath) as? CommentCell else {
                fatalError("Cannot dequeue CommentCell")
            }
            
            guard let comment = comments?[indexPath.row],
                    !commentSenders.isEmpty else {
                return commentCell
            }
            
            let commentSender = commentSenders[indexPath.row]
            
            commentCell.configureCell(userPhoto: commentSender.userImage,
                                      userName: commentSender.name,
                                      comment: comment)
            
            return commentCell
            
        default:
            return UITableViewCell()
        }
    }
}
