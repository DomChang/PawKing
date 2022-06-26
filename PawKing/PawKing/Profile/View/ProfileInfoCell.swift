//
//  ProfileInfoCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/19.
//

import UIKit
 
@objc protocol ProfileInfoCellDelegate: AnyObject {
    
    @objc optional func didTapUserImage()
    
    func didTapLeftButton()
    
    func didTapRightButton()
}

class ProfileInfoCell: UICollectionViewCell {
    
    static let identifier = "\(ProfileInfoCell.self)"
    
    var delegate: ProfileInfoCellDelegate?
    
    let userImageView = UIImageView()
    
    let userNameLabel = UILabel()
    
//    let userDescriptionLabel = UILabel()
    
    let postNumLabel = UILabel()

    let postNumTitleLabel = UILabel()
    
    let friendNumLabel = UILabel()
    
    let friendNumTitleLabel = UILabel()
    
    let leftButton = UIButton()
    
    let rightButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        leftButton.addTarget(self, action: #selector(didTapLeftButton), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)
        
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                  action: #selector(didTapUserImage)))
        userImageView.isUserInteractionEnabled = true
    }
    
    private func style() {
        
        userImageView.contentMode = .scaleAspectFill
        
        friendNumTitleLabel.text = "Friends"
        friendNumTitleLabel.textAlignment = .center
        friendNumTitleLabel.textColor = .LightBlack
        friendNumTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        friendNumLabel.textAlignment = .center
        friendNumLabel.textColor = .LightBlack
        friendNumLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        postNumTitleLabel.text = "Posts"
        postNumTitleLabel.textAlignment = .center
        postNumTitleLabel.textColor = .LightBlack
        postNumTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        postNumLabel.textAlignment = .center
        postNumLabel.textColor = .LightBlack
        postNumLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        userNameLabel.textColor = .LightBlack
        userNameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        userNameLabel.numberOfLines = 0
        
        leftButton.layer.borderWidth = 1
        leftButton.layer.borderColor = UIColor.O1?.cgColor
        leftButton.backgroundColor = .white
        leftButton.setTitleColor(.O1, for: .normal)
        leftButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        rightButton.layer.borderWidth = 1
        rightButton.layer.borderColor = UIColor.O1?.cgColor
        rightButton.backgroundColor = .white
        rightButton.setTitleColor(.O1, for: .normal)
        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    }
    
    private func layout() {
        
        let vFriendStack = UIStackView(arrangedSubviews: [friendNumTitleLabel, friendNumLabel])
        
        vFriendStack.axis = .vertical
        vFriendStack.distribution = .fillProportionally
        vFriendStack.spacing = 3
        
        let vPostStack = UIStackView(arrangedSubviews: [postNumTitleLabel, postNumLabel])
        
        vPostStack.axis = .vertical
        vPostStack.distribution = .fillProportionally
        vPostStack.spacing = 3
        
        let hStack = UIStackView(arrangedSubviews: [vPostStack, vFriendStack])
        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        
        let buttonStackView = UIStackView(arrangedSubviews: [leftButton, rightButton])
        
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 20
        
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
//        contentView.addSubview(userDescriptionLabel)
//        contentView.addSubview(postNumLabel)
//        contentView.addSubview(postNumTitleLabel)
//        contentView.addSubview(friendNumLabel)
//        contentView.addSubview(friendNumTitleLabel)
        contentView.addSubview(hStack)
        contentView.addSubview(buttonStackView)
        
        userImageView.anchor(top: contentView.topAnchor,
                             leading: contentView.leadingAnchor,
                             width: 60,
                             height: 60,
                             padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 0))
        
        userNameLabel.anchor(leading: userImageView.trailingAnchor,
                             centerY: userImageView.centerYAnchor,
                             width: 120,
                             height: 20,
                             padding: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
        
        hStack.anchor(top: userImageView.topAnchor,
                      leading: userNameLabel.trailingAnchor,
                      bottom: userImageView.bottomAnchor,
                      trailing: contentView.trailingAnchor,
                      padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 25))
        
//        userDescriptionLabel.anchor(top: userNameLabel.bottomAnchor,
//                                    leading: userNameLabel.leadingAnchor,
//                                    bottom: contentView.bottomAnchor,
//                                    trailing: userNameLabel.trailingAnchor,
//                                    padding: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
        
//        friendNumTitleLabel.anchor(top: userImageView.topAnchor,
//                                   trailing: contentView.trailingAnchor,
//                                   width: 60,
//                                   height: 20,
//                                   padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 100))
//
//        friendNumLabel.anchor(top: friendNumTitleLabel.bottomAnchor,
//                              centerX: friendNumTitleLabel.centerXAnchor,
//                              width: 60,
//                              height: 30,
//                              padding: UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0))
//
//        postNumTitleLabel.anchor(trailing: friendNumTitleLabel.leadingAnchor,
//                                 centerY: friendNumTitleLabel.centerYAnchor,
//                                 width: 40,
//                                 height: 20,
//                                 padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20))
//
//        postNumLabel.anchor(centerY: friendNumLabel.centerYAnchor,
//                            centerX: postNumTitleLabel.centerXAnchor,
//                            width: 50,
//                            height: 30)
        
        buttonStackView.anchor(top: userImageView.bottomAnchor,
                               leading: contentView.leadingAnchor,
                               trailing: contentView.trailingAnchor,
                               height: 40,
                               padding: UIEdgeInsets(top: 20, left: 30, bottom: 0, right: 30))
        
        contentView.layoutIfNeeded()
        userImageView.layer.cornerRadius = 5
        userImageView.clipsToBounds = true
        
        leftButton.layer.cornerRadius = 5
        rightButton.layer.cornerRadius = 5
    }
    
    func configureCell(user: User, postCount: Int) {
        
        let imageUrl = URL(string: user.userImage)
        
        userImageView.kf.setImage(with: imageUrl)
        
        userNameLabel.text = user.name
        
        postNumLabel.text = "\(postCount)"
        
        friendNumLabel.text = "\(user.friends.count)"
    }
    
    @objc func didTapUserImage() {
        
        self.delegate?.didTapUserImage?()
    }
    
    @objc func didTapLeftButton() {
        
        self.delegate?.didTapLeftButton()
    }
    
    @objc func didTapRightButton() {
        
        self.delegate?.didTapRightButton()
    }
}
