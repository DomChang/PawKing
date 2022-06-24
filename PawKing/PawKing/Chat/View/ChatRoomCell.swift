//
//  ChatRoomCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/24.
//

import UIKit

class ChatRoomCell: UITableViewCell {
    
    static let identifier = "\(ChatRoomCell.self)"
    
    private let recieverImgeView = UIImageView()
    
    private let recieverNameLabel = UILabel()
    
    private let recentMessageLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
        styleObject()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
    }
    
    func styleObject() {
        
        recieverNameLabel.textColor = .brown
        recieverNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        recieverNameLabel.textAlignment = .left
        
        recentMessageLabel.textColor = .black
        recentMessageLabel.font = UIFont.systemFont(ofSize: 16)
        recentMessageLabel.textAlignment = .left
    }
    
    func layout() {
        
        recieverImgeView.constrainWidth(constant: 30)
        recieverImgeView.constrainHeight(constant: 30)
        recieverImgeView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let vStack = UIStackView(arrangedSubviews: [recieverNameLabel, recentMessageLabel])
        
        vStack.axis = .vertical
        vStack.distribution = .fillEqually
        vStack.spacing = 8
        
        let hStack = UIStackView(arrangedSubviews: [recieverImgeView, vStack])
        
        hStack.axis = .horizontal
        hStack.distribution = .fill
        hStack.spacing = 8
        
        contentView.addSubview(hStack)
        
        hStack.anchor(top: contentView.topAnchor,
                      leading: contentView.leadingAnchor,
                      bottom: contentView.bottomAnchor,
                      trailing: contentView.trailingAnchor,
                      padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        
        recieverImgeView.layoutIfNeeded()
        recieverImgeView.makeRound()
        recieverImgeView.clipsToBounds = true
    }
    
    func configureCell(user: User, recentMessage: Message) {
        
        let imageUrl = URL(string: user.userImage)
        
        recieverImgeView.kf.setImage(with: imageUrl)
        
        recieverNameLabel.text = user.name
        
        recentMessageLabel.text = recentMessage.content
    }
}
