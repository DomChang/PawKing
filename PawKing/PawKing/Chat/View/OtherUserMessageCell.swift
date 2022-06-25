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
        
        contentView.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        
        otherUserTextView.isUserInteractionEnabled = false
        otherUserTextView.font = UIFont.systemFont(ofSize: 15)
        otherUserTextView.textColor = .black
        otherUserTextView.backgroundColor = .white
        otherUserTextView.isScrollEnabled = false
        otherUserTextView.layer.cornerRadius = 5
        
        timeLabel.font = UIFont.systemFont(ofSize: 10)
        timeLabel.textAlignment = .left
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
            otherUserTextView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
            otherUserTextView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -50),
            
            timeLabel.bottomAnchor.constraint(equalTo: otherUserTextView.bottomAnchor),
            timeLabel.heightAnchor.constraint(equalToConstant: 15),
            timeLabel.leadingAnchor.constraint(equalTo: otherUserTextView.trailingAnchor, constant: 5),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -10),
            
            otherUserImageView.centerYAnchor.constraint(equalTo: otherUserTextView.centerYAnchor),
            otherUserImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            otherUserImageView.heightAnchor.constraint(equalToConstant: 30),
            otherUserImageView.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configureCell(otherUser: User, message: Message) {
        
        let imageUrl = URL(string: otherUser.userImage)
        
        otherUserImageView.kf.setImage(with: imageUrl)
        
        otherUserTextView.text = message.content
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "hh:mm"
        
        let messageDate = dateFormatter.string(from: message.createdTime.dateValue())
        
        timeLabel.text = messageDate
    }
}
