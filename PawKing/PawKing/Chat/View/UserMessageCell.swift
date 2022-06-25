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
        
        contentView.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        
        userTextView.isUserInteractionEnabled = false
        userTextView.font = UIFont.systemFont(ofSize: 15)
        userTextView.textColor = .white
        userTextView.backgroundColor = UIColor(red: 63/255, green: 58/255, blue: 58/255, alpha: 1)
        userTextView.isScrollEnabled = false
        userTextView.layer.borderWidth = 0.8
        userTextView.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        userTextView.layer.cornerRadius = 5
        
        timeLabel.font = UIFont.systemFont(ofSize: 10)
        timeLabel.textAlignment = .right
    }
    
    private func layout() {
        
        userTextView.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(userTextView)
        contentView.addSubview(timeLabel)

        NSLayoutConstraint.activate([
            userTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            userTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            userTextView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
            userTextView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 50),
            
            timeLabel.bottomAnchor.constraint(equalTo: userTextView.bottomAnchor),
            timeLabel.heightAnchor.constraint(equalToConstant: 15),
            timeLabel.trailingAnchor.constraint(equalTo: userTextView.leadingAnchor, constant: -5),
            timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 10)
        ])
    }
    
    func configuerCell(message: Message) {
        
        userTextView.text = message.content
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "hh:mm"
        
        let messageDate = dateFormatter.string(from: message.createdTime.dateValue())
        
        timeLabel.text = messageDate
    }
}
