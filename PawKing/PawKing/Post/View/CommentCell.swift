//
//  CommentCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/22.
//

import UIKit

protocol CommentCellDelegate: AnyObject {
    
    func didTapCommentUser(from cell: CommentCell)
}

class CommentCell: UITableViewCell {
    
    static let identifier = "\(CommentCell.self)"
    
    weak var delegate: CommentCellDelegate?
    
    private let userImageView = UIImageView()
    
    private let userNameLabel = UILabel()
    
    private let commentLabel = UILabel()
    
    private let timeLabel = UILabel()
    
    var userId: String?

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
        
        selectionStyle = .none
        
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                  action: #selector(didTapCommentUser)))
        
        userNameLabel.isUserInteractionEnabled = true
        userNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                  action: #selector(didTapCommentUser)))
    }
    
    private func styleObject() {
        
        userImageView.contentMode = .scaleAspectFill
        
        userNameLabel.textColor = .BattleGrey
        userNameLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        
        commentLabel.textColor = .LightBlack
        commentLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        timeLabel.textColor = .MainGray
        timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        timeLabel.textAlignment = .left
    }
    
    private func layout() {
        
        userNameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let hStackView = UIStackView(arrangedSubviews: [userNameLabel, commentLabel])

        hStackView.axis = .horizontal
        hStackView.distribution = .fill
        hStackView.spacing = 8
        
        let vStackView = UIStackView(arrangedSubviews: [hStackView, timeLabel])
        
        vStackView.axis = .vertical
        vStackView.distribution = .fill
        vStackView.spacing = 8
        
        contentView.addSubview(userImageView)
        
        contentView.addSubview(vStackView)
        
        userImageView.anchor(top: contentView.topAnchor,
                             leading: contentView.leadingAnchor,
                             width: 30,
                             height: 30,
                             padding: UIEdgeInsets(top: 8, left: 20, bottom: 0, right: 0))
        
        vStackView.anchor(top: userImageView.topAnchor,
                         leading: userImageView.trailingAnchor,
                         bottom: contentView.bottomAnchor,
                         trailing: contentView.trailingAnchor,
                         padding: UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 10))
        
        userImageView.layoutIfNeeded()
        userImageView.makeRound()
        userImageView.clipsToBounds = true
    }
    
    func configureCell(user: User, comment: Comment) {
        
        let imageUrl = URL(string: user.userImage)
        
        userImageView.kf.setImage(with: imageUrl)
        
        userNameLabel.text = user.name
        
        commentLabel.text = comment.text
        
        timeLabel.text = comment.createdTime.dateValue()
            .displayTimeInSocialMediaStyle()
        
        self.userId = user.id
    }
    
    @objc private func didTapCommentUser() {
        
        self.delegate?.didTapCommentUser(from: self)
    }
}
