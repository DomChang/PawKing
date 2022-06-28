//
//  OtherUserMessageCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/24.
//

import UIKit

class OtherUserMessageCell: UITableViewCell {

    static let identifer = "\(OtherUserMessageCell.self)"
    
    let otherUserTextView = UITextView()
    let otherUserImageView = UIImageView()
    let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
        styleObject()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        
    }
    
    func styleObject() {
        
        contentView.backgroundColor = .white
        
        otherUserImageView.contentMode = .scaleAspectFill
        
        otherUserTextView.isUserInteractionEnabled = false
        otherUserTextView.font = UIFont.systemFont(ofSize: 18)
        otherUserTextView.textColor = .LightBlack
        otherUserTextView.backgroundColor = .LightGray
        otherUserTextView.isScrollEnabled = false
        otherUserTextView.layer.borderWidth = 0.2
        otherUserTextView.layer.borderColor = UIColor.Blue1?.cgColor
        otherUserTextView.layer.cornerRadius = 10
        otherUserTextView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        otherUserTextView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        
        timeLabel.font = UIFont.systemFont(ofSize: 10)
        timeLabel.textAlignment = .left
        timeLabel.textColor = .Blue1
    }
    
    func layout() {
        
        otherUserTextView.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        otherUserImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(otherUserTextView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(otherUserImageView)

        NSLayoutConstraint.activate([
            otherUserTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            otherUserTextView.leadingAnchor.constraint(equalTo: otherUserImageView.trailingAnchor, constant: 15),
            otherUserTextView.bottomAnchor.constraint(lessThanOrEqualTo: timeLabel.topAnchor, constant: -3),
            otherUserTextView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -50),
            
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            timeLabel.leadingAnchor.constraint(equalTo: otherUserTextView.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            otherUserImageView.centerYAnchor.constraint(equalTo: otherUserTextView.centerYAnchor),
            otherUserImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            otherUserImageView.heightAnchor.constraint(equalToConstant: 30),
            otherUserImageView.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        contentView.layoutIfNeeded()
        otherUserImageView.makeRound()
        otherUserImageView.clipsToBounds = true
    }
    
    func configureCell(otherUser: User, message: Message) {
        
        let imageUrl = URL(string: otherUser.userImage)
        
        otherUserImageView.kf.setImage(with: imageUrl)
        
        otherUserTextView.text = message.content
        
        timeLabel.text = message.createdTime.dateValue().displayTimeInChatStyle()
    }
}
