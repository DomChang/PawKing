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
    
    private let userInputTextfield = UITextField()
    
    private let sendButton = UIButton()
    
    private let inputBackView = UIView()
    
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
    }
    
    func setup() {
        
        tableView.register(UserMessageCell.self, forCellReuseIdentifier: UserMessageCell.identifer)
        tableView.register(OtherUserMessageCell.self, forCellReuseIdentifier: OtherUserMessageCell.identifer)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        userInputTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)),
                                  for: .editingChanged)
        
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
    }
    
    func style() {
        
        view.backgroundColor = .gray
        
        tableView.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        tableView.separatorStyle = .none
        
        sendButton.isEnabled = false
        
        userInputTextfield.backgroundColor = .white
        userInputTextfield.layer.cornerRadius = 3
        userInputTextfield.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        userInputTextfield.layer.borderWidth = 0.8
        
        sendButton.layer.cornerRadius = 3
        sendButton.setTitle("發送", for: .normal)
        sendButton.backgroundColor = .O1
        
        inputBackView.layer.borderWidth = 0.8
        inputBackView.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        inputBackView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
    }
    
    func layout() {
        
        view.addSubview(tableView)
        view.addSubview(inputBackView)
        view.addSubview(userInputTextfield)
        view.addSubview(sendButton)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         leading: view.leadingAnchor,
                         bottom: inputBackView.topAnchor,
                         trailing: view.trailingAnchor)
        
        userInputTextfield.anchor(top: inputBackView.topAnchor,
                                 leading: view.leadingAnchor,
                                 bottom: inputBackView.bottomAnchor,
                                 trailing: view.trailingAnchor,
                                 height: 36,
                                 padding: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 70))
        
        inputBackView.anchor(leading: view.leadingAnchor,
                             bottom: view.safeAreaLayoutGuide.bottomAnchor,
                             trailing: view.trailingAnchor,
                             centerY: userInputTextfield.centerYAnchor,
                             padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        sendButton.anchor(top: userInputTextfield.topAnchor,
                          leading: userInputTextfield.trailingAnchor,
                          bottom: userInputTextfield.bottomAnchor,
                          trailing: view.trailingAnchor,
                          centerY: userInputTextfield.centerYAnchor,
                         padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 16))
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
        
        sendButton.isEnabled = false
        
        guard let messageContent = userInputTextfield.text else { return }
        
        let message = Message(otherUserId: otherUser.id,
                              senderId: user.id,
                              recieverId: otherUser.id,
                              content: messageContent,
                              createdTime: Timestamp(date: Date()))
        
        chatManager.sendMessage(message: message) { [weak self] result in
            
            switch result {
                
            case .success:
                
                self?.messages.append(message)
                
            case .failure(let error):
                
                print(error)
            }
        }
        
        userInputTextfield.text = ""
        
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
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        guard textField == userInputTextfield else { return }

        if textField.text != "" {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
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
