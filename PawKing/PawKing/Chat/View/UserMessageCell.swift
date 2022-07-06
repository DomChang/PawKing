//
//  UserMessageCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/24.
//

import UIKit

class UserMessageCell: UITableViewCell {

    static let identifer = "\(UserMessageCell.self)"
    
    let userTextView = UITextView()
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
    
    private func setUp() {
        
    }
    
    private func styleObject() {
        
        contentView.backgroundColor = .white
        
        userTextView.isUserInteractionEnabled = false
        userTextView.font = UIFont.systemFont(ofSize: 18)
        userTextView.textColor = .white
        userTextView.backgroundColor = .BattleGrey
        userTextView.isScrollEnabled = false
        userTextView.layer.borderWidth = 0.2
        userTextView.layer.borderColor = UIColor.LightBlack?.cgColor
        userTextView.layer.cornerRadius = 10
        userTextView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        userTextView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        
        timeLabel.font = UIFont.systemFont(ofSize: 10)
        timeLabel.textAlignment = .right
        timeLabel.textColor = .Blue1
    }
    
    private func layout() {
        
        userTextView.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(userTextView)
        contentView.addSubview(timeLabel)

        NSLayoutConstraint.activate([
            userTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            userTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            userTextView.bottomAnchor.constraint(lessThanOrEqualTo: timeLabel.topAnchor, constant: -3),
            userTextView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 50),
            
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            timeLabel.trailingAnchor.constraint(equalTo: userTextView.trailingAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
    }
    
    func configuerCell(message: Message) {
        
        userTextView.text = message.content
        
        timeLabel.text = message.createdTime.dateValue().displayTimeInChatStyle()
    }
}
