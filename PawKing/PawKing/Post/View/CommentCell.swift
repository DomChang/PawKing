//
//  CommentCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/22.
//

import UIKit

class CommentCell: UITableViewCell {
    
    static let identifier = "\(CommentCell.self)"
    
    let userImageView = UIImageView()
    
    let userNameLabel = UILabel()
    
    let commentLabel = UILabel()
    
    let timeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
        styleObject()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
    }
    
    private func styleObject() {
        
        userNameLabel.textColor = .brown
        userNameLabel.font = UIFont.systemFont(ofSize: 18)
        
        commentLabel.textColor = .brown
        commentLabel.font = UIFont.systemFont(ofSize: 18)
        
        timeLabel.textColor = .brown
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textAlignment = .right
    }
    
    private func layout() {
        
        userImageView.constrainWidth(constant: 30)
        userImageView.constrainHeight(constant: 30)
        
        userNameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let hStackView = UIStackView(arrangedSubviews: [userImageView, userNameLabel, commentLabel])
        
        hStackView.axis = .horizontal
        
        hStackView.distribution = .fill
        
        hStackView.spacing = 8
        
        let vStackView = UIStackView(arrangedSubviews: [hStackView, timeLabel])
        
        vStackView.axis = .vertical
        
        vStackView.distribution = .fill
        
        contentView.addSubview(vStackView)
        
        vStackView.anchor(top: contentView.topAnchor,
                         leading: contentView.leadingAnchor,
                         bottom: contentView.bottomAnchor,
                         trailing: contentView.trailingAnchor,
                         padding: UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10))
        
        userImageView.layoutIfNeeded()
        userImageView.makeRound()
        userImageView.clipsToBounds = true
    }
    
    func configureCell(userPhoto: String, userName: String, comment: Comment) {
        
        let imageUrl = URL(string: userPhoto)
        
        userImageView.kf.setImage(with: imageUrl)
        
        userNameLabel.text = userName
        
        commentLabel.text = comment.text
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let commentDate = dateFormatter.string(from: comment.createdTime.dateValue())
        
        timeLabel.text = commentDate
    }
}
