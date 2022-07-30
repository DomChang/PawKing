//
//  MessageViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/24.
//

import UIKit
import FirebaseFirestore
import IQKeyboardManagerSwift

class MessageViewController: UIViewController {
    
    private let user: User
    
    private let otherUser: User
    
    private let otherUserId: String
    
    private let tableView = UITableView()
    
    private let userImageView = UIImageView()
    
    private let userInputTextView = InputTextView()
    
    private let sendButton = UIButton()
    
    private let inputBackView = UIView()
    
    private let inputSeperatorLine = UIView()
    
    private let bottomBackView = UIView()
    
    private var userInputTopAnchor: NSLayoutConstraint!
    
    private var messageLisener: ListenerRegistration?
    
    var messages: [Message] = [] {
        didSet {
            tableView.reloadData()
            scrollToBottom()
        }
    }
    
    init(user: User, otherUser: User, otherUserId: String) {
        
        self.user = user
        self.otherUser = otherUser
        self.otherUserId = otherUserId
        
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
        
        listenMessage()
        
        tabBarController?.tabBar.isHidden = true
        
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        tabBarController?.tabBar.isHidden = false
        
        IQKeyboardManager.shared.enable = true
        
        messageLisener?.remove()
    }
    
    func setup() {
        
        navigationItem.title = "\(otherUser.name)"
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        tableView.register(UserMessageCell.self, forCellReuseIdentifier: UserMessageCell.identifer)
        tableView.register(OtherUserMessageCell.self, forCellReuseIdentifier: OtherUserMessageCell.identifer)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        userInputTextView.isScrollEnabled = false
        
        if otherUser.id == UserStatus.unknown.rawValue {
            
            userInputTextView.placeholder = "User not found"
            userInputTextView.isEditable = false
            
        } else {
            
            userInputTextView.placeholder = "Aa"
        }
        
        userInputTextView.delegate = self
        
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillAppear(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    func style() {
        
        view.backgroundColor = .BattleGrey
        
        tableView.layer.cornerRadius = 20
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
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
        
        bottomBackView.backgroundColor = .white
    }
    
    func layout() {
        
        view.addSubview(tableView)
        view.addSubview(inputBackView)
        view.addSubview(inputSeperatorLine)
        inputBackView.addSubview(userImageView)
        inputBackView.addSubview(userInputTextView)
        inputBackView.addSubview(sendButton)
        view.addSubview(bottomBackView)
        
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
                          padding: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 16))
        
        inputBackView.anchor(leading: view.leadingAnchor,
                             trailing: view.trailingAnchor)
        
        userInputTopAnchor = inputBackView.bottomAnchor.constraint(equalTo:
                                                                    view.safeAreaLayoutGuide.bottomAnchor)
        userInputTopAnchor.isActive = true
        
        inputSeperatorLine.anchor(leading: inputBackView.leadingAnchor,
                                  bottom: inputBackView.topAnchor,
                                  trailing: inputBackView.trailingAnchor,
                                  height: 0.5)
        
        bottomBackView.anchor(top: inputBackView.bottomAnchor,
                              leading: view.leadingAnchor,
                              bottom: view.bottomAnchor,
                              trailing: view.trailingAnchor)
        
        inputBackView.layoutIfNeeded()
        userImageView.makeRound()
        userImageView.clipsToBounds = true
    }
    
    func listenMessage() {
        
        if messageLisener != nil {
            
            messageLisener?.remove()
        }

        messageLisener = ChatManager.shared.listenNewMessage(user: user, otherUser: otherUser) { [weak self] result in

            switch result {

            case .success(let messages):
                
                guard let self = self else { return }

                self.messages.append(contentsOf: messages)
                
                ChatManager.shared.updateMessageStatus(user: self.user,
                                                     otherUser: self.otherUser)
                
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
                              createdTime: Timestamp(date: Date()),
                              isRead: MessageStatus.notRead.rawValue)
        
        ChatManager.shared.sendMessage(message: message) { [weak self] result in
            
            switch result {
                
            case .success:
                
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
    
    func sendButtonEnable() {
        
        sendButton.isEnabled = true
        sendButton.tintColor = .CoralOrange
    }
    
    func sendButtonDisable() {
        
        sendButton.isEnabled = false
        sendButton.tintColor = .MainGray
    }
    
    @objc func keyboardWillAppear(notification: Notification) {
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            let keyboardHeight = keyboardRectangle.height
            
            userInputTopAnchor.constant = -keyboardHeight + view.safeAreaInsets.bottom
            
            scrollToBottom()
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        
        userInputTopAnchor.constant = 0
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
