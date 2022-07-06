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
    
    private let messageTimeLabel = UILabel()

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
        
        selectionStyle = .none
    }
    
    func styleObject() {
        
        recieverImgeView.contentMode = .scaleAspectFill
        
        recieverNameLabel.textColor = .BattleGrey
        recieverNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        recieverNameLabel.textAlignment = .left
        
        recentMessageLabel.textColor = .Gray1
        recentMessageLabel.font = UIFont.systemFont(ofSize: 16)
        recentMessageLabel.textAlignment = .left
        
        messageTimeLabel.textColor = .Gray1
        messageTimeLabel.font = UIFont.systemFont(ofSize: 14)
        messageTimeLabel.textAlignment = .right
    }
    
    func layout() {
        
        recieverImgeView.constrainWidth(constant: 50)
        recieverImgeView.constrainHeight(constant: 50)
        recieverImgeView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        recieverNameLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        messageTimeLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let hMessageStack = UIStackView(arrangedSubviews: [recentMessageLabel, messageTimeLabel])
        
        hMessageStack.axis = .horizontal
        hMessageStack.distribution = .fill
        hMessageStack.spacing = 8
        
        let vStack = UIStackView(arrangedSubviews: [recieverNameLabel, hMessageStack])
        
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
                      padding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        
        recieverImgeView.layoutIfNeeded()
        recieverImgeView.makeRound()
        recieverImgeView.clipsToBounds = true
    }
    
    func configureCell(user: User, recentMessage: Message) {
        
        let imageUrl = URL(string: user.userImage)
        
        recieverImgeView.kf.setImage(with: imageUrl)
        
        recieverNameLabel.text = user.name
        
        recentMessageLabel.text = recentMessage.content
        
        messageTimeLabel.text = recentMessage.createdTime.dateValue().displayTimeInSocialMediaStyle()
    }
}
