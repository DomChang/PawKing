//
//  MessageViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/24.
//

import UIKit
import FirebaseFirestore

class MessageViewController: UIViewController {
    
    private let chatManager = ChatManager.shared
    
    private let user: User
    
    private let otherUser: User
    
    private let tableView = UITableView()
    
    private let userImageView = UIImageView()
    
    private let userInputTextView = InputTextView()
    
    private let sendButton = UIButton()
    
    private let inputBackView = UIView()
    
    private let inputSeperatorLine = UIView()
    
    var messages: [Message] = [] {
        didSet {
            tableView.reloadData()
            scrollToBottom()
        }
    }
    
    init(user: User, otherUser: User) {
        
        self.user = user
        self.otherUser = otherUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listenMessage()
        setup()
        style()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getMessageHistory()
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        tabBarController?.tabBar.isHidden = false
    }
    
    func setup() {
        
        navigationItem.title = "\(otherUser.name)"
        
        navigationController?.navigationBar.tintColor = .Orange1
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        tableView.register(UserMessageCell.self, forCellReuseIdentifier: UserMessageCell.identifer)
        tableView.register(OtherUserMessageCell.self, forCellReuseIdentifier: OtherUserMessageCell.identifer)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        userInputTextView.isScrollEnabled = false
        userInputTextView.placeholder = "Aa"
        userInputTextView.delegate = self
        
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
    }
    
    func style() {
        
        view.backgroundColor = .white
        
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        
        sendButtonDisable()
        
        inputSeperatorLine.backgroundColor = .lightGray
        
        let imageUrl = URL(string: user.userImage)
        userImageView.kf.setImage(with: imageUrl)
        userImageView.contentMode = .scaleAspectFill
        
        userInputTextView.backgroundColor = .white
        userInputTextView.font = UIFont.systemFont(ofSize: 18)
        
        sendButton.setImage(UIImage(systemName: "paperplane.fill",
                                    withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
                            for: .normal)
        sendButton.setImage(UIImage(systemName: "paperplane",
                                    withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
                            for: .disabled)
        
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
                         trailing: view.trailingAnchor)
        
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
    
    func getMessageHistory() {
        
        chatManager.fetchMessageHistory(user: user, otherUser: otherUser) { [weak self] result in
            
            switch result {
                
            case .success(let messages):
                
                self?.messages = messages
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func listenMessage() {
        
        chatManager.listenNewMessage(user: user, otherUser: otherUser) { [weak self] result in
                
            switch result {
                
            case .success(let messages):
                
                self?.messages.append(contentsOf: messages)
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    @objc func didTapSendButton() {
        
        sendButtonDisable()
        
        guard let messageContent = userInputTextView.text else { return }
        
        let message = Message(otherUserId: otherUser.id,
                              senderId: user.id,
                              recieverId: otherUser.id,
                              content: messageContent,
                              createdTime: Timestamp(date: Date()))
        
        chatManager.sendMessage(message: message) { [weak self] result in
            
            switch result {
                
            case .success:
                
                self?.messages.append(message)
                
                self?.userInputTextView.text = ""
                
            case .failure(let error):
                
                print(error)
            }
        }
        
        DispatchQueue.main.async { [self] in
            
            tableView.reloadData()
            
            scrollToBottom()
        }
    }
    
//    @objc func keyboardWillShow(sender: NSNotification) {
//        userInputTopAnchor.constant = -352
//    }
//
//    @objc func keyboardWillHide(sender: NSNotification) {
//        userInputTopAnchor.constant = -52
//    }
//
    func sendButtonEnable() {
        
        sendButton.isEnabled = true
        sendButton.tintColor = .Orange1
    }
    
    func sendButtonDisable() {
        
        sendButton.isEnabled = false
        sendButton.tintColor = .Gray1
    }
    
    func scrollToBottom() {
        
        let rows = tableView.numberOfRows(inSection: 0)
        
        if rows > 0 {
            
            let last = IndexPath(row: rows - 1, section: 0)

            DispatchQueue.main.async {

                self.tableView.scrollToRow(at: last, at: .bottom, animated: false)
            }
        }
    }
}

extension MessageViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        if message.senderId == user.id {

            guard let userCell = tableView.dequeueReusableCell(withIdentifier: UserMessageCell.identifer, for: indexPath
            ) as? UserMessageCell else {
                fatalError("Can not create UserMessageCell")
            }
            
            userCell.configuerCell(message: message)
            
            return userCell

        } else {

            guard let otherUserCell = tableView.dequeueReusableCell(withIdentifier: OtherUserMessageCell.identifer,
                                                                    for: indexPath
            ) as? OtherUserMessageCell else {
                fatalError("Can not create OtherUserMessageCell")
            }
            
            otherUserCell.configureCell(otherUser: otherUser, message: message)

            return otherUserCell
        }
    }
}

extension MessageViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView == userInputTextView else { return }
        
        if textView.text.isEmpty {
            
            sendButtonDisable()
        } else {
            
            sendButtonEnable()
        }
    }
}
