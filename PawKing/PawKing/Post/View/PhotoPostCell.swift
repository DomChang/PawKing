//
//  PhotoPostCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/22.
//

import UIKit

class PhotoPostCell: UITableViewCell {
    
    static let identifier = "\(PhotoItemCell.self)"
    
    let petImageView = UIImageView()
    
    let petNameLabel = UILabel()
    
    let settingButton = UIButton()
    
    let photoImageView = UIImageView()
    
    let likeButton = UIButton()
    
    let likeNumLabel = UILabel()
    
    let commentButton = UIButton()
    
    let nameContentLabel = UILabel()
    
    let contentLabel = UILabel()
    
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
        
    }
    
    private func layout() {
        
        let contentBodyStack = UIStackView(arrangedSubviews:
                                            [nameContentLabel, contentLabel])
        
        nameContentLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        contentBodyStack.spacing = 8
        
        contentBodyStack.distribution = .fill
        contentBodyStack.axis = .horizontal
        
        let contentStack = UIStackView(arrangedSubviews:
                                        [contentBodyStack, timeLabel])
        
        contentStack.distribution = .equalSpacing
        contentStack.axis = .vertical
        contentStack.spacing = 8
        
        contentView.addSubview(petImageView)
        contentView.addSubview(petNameLabel)
        contentView.addSubview(settingButton)
        contentView.addSubview(photoImageView)
        contentView.addSubview(likeButton)
        contentView.addSubview(likeNumLabel)
        contentView.addSubview(commentButton)
        contentView.addSubview(contentStack)
        
        petImageView.anchor(top: contentView.topAnchor,
                             leading: contentView.leadingAnchor,
                             width: 30,
                             height: 30,
                             padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 0))
        
        petNameLabel.anchor(leading: petImageView.trailingAnchor,
                             centerY: petImageView.centerYAnchor,
                             padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        
        settingButton.anchor(leading: petNameLabel.trailingAnchor,
                             trailing: contentView.trailingAnchor,
                             centerY: petImageView.centerYAnchor,
                             width: 30,
                             height: 30,
                             padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20))
        
        photoImageView.anchor(top: petNameLabel.bottomAnchor,
                              leading: contentView.leadingAnchor,
                              trailing: contentView.trailingAnchor,
                              height: contentView.frame.width,
                             padding: UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0))
        
        likeButton.anchor(top: photoImageView.bottomAnchor,
                          leading: petImageView.leadingAnchor,
                             width: 30,
                             height: 30,
                             padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        
        likeNumLabel.anchor(leading: likeButton.trailingAnchor,
                            centerY: likeButton.centerYAnchor,
                             padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        
        commentButton.anchor(leading: likeNumLabel.trailingAnchor,
                             trailing: contentView.trailingAnchor,
                             centerY: likeButton.centerYAnchor,
                             width: 30,
                             height: 30,
                             padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20))
        
        contentStack.anchor(top: likeButton.bottomAnchor,
                            leading: likeButton.leadingAnchor,
                            bottom: contentView.bottomAnchor,
                            trailing: commentButton.trailingAnchor,
                             padding: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
    }
    
    func configureCell(user: User, pet: Pet, post: Post) {
        
        let petUrl = URL(string: pet.petImage)
        
        petImageView.kf.setImage(with: petUrl)
        
        petNameLabel.text = pet.name
        
        let photoUrl = URL(string: post.photo)
        
        photoImageView.kf.setImage(with: photoUrl)
        
        likeNumLabel.text = "\(post.likesId.count)"
        
        nameContentLabel.text = user.name
        
        contentLabel.text = post.caption
        
        let commentCount = post.commentsId.count
        
//        if commentCount > 0 {
//            
//            viewCommentLabel.text = "View all \(post.commentsId.count) comments"
//            
//        } else {
//            
//            viewCommentLabel.text = "write comment"
//        }
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let postDate = dateFormatter.string(from: post.createdTime.dateValue())
        
        timeLabel.text = postDate
    }
}
