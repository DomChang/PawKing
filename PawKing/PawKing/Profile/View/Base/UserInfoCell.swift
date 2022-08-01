//
//  ProfileInfoCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/19.
//

import UIKit
 
protocol UserInfoCellDelegate: AnyObject {

    func didTapLeftButton()
    
    func didTapRightButton()
    
    func didTapFriend()
}

class UserInfoCell: UICollectionViewCell {
    
    weak var delegate: UserInfoCellDelegate?
    
    let userImageView = UIImageView()
    
    let userNameLabel = UILabel()

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
    }
    
    private func style() {
        
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.borderColor = UIColor.white.cgColor
        userImageView.layer.borderWidth = 1
        
        friendNumTitleLabel.text = "Friends"
        friendNumTitleLabel.textAlignment = .center
        friendNumTitleLabel.textColor = .white
        friendNumTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        friendNumLabel.textAlignment = .center
        friendNumLabel.textColor = .white
        friendNumLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        postNumTitleLabel.text = "Posts"
        postNumTitleLabel.textAlignment = .center
        postNumTitleLabel.textColor = .white
        postNumTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        postNumLabel.textAlignment = .center
        postNumLabel.textColor = .white
        postNumLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        userNameLabel.textColor = .white
        userNameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        userNameLabel.numberOfLines = 0
        
        leftButton.layer.borderWidth = 1
        leftButton.layer.borderColor = UIColor.white.cgColor
        leftButton.backgroundColor = .BattleGrey
        leftButton.setTitleColor(.white, for: .normal)
        leftButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        rightButton.layer.borderWidth = 1
        rightButton.layer.borderColor = UIColor.white.cgColor
        rightButton.backgroundColor = .BattleGrey
        rightButton.setTitleColor(.white, for: .normal)
        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    private func layout() {
        
        let vFriendStack = UIStackView(arrangedSubviews: [friendNumTitleLabel, friendNumLabel])
        
        vFriendStack.axis = .vertical
        vFriendStack.distribution = .fillProportionally
        vFriendStack.spacing = 3
        vFriendStack.isUserInteractionEnabled = true
        vFriendStack.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                 action: #selector(didTapFriend)))
        
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
        contentView.addSubview(hStack)
        contentView.addSubview(buttonStackView)
        
        userImageView.anchor(top: contentView.topAnchor,
                             leading: contentView.leadingAnchor,
                             width: 60,
                             height: 60,
                             padding: UIEdgeInsets(top: 20, left: 25, bottom: 0, right: 0))
        
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
        
        buttonStackView.anchor(top: userImageView.bottomAnchor,
                               leading: contentView.leadingAnchor,
                               trailing: contentView.trailingAnchor,
                               height: 30,
                               padding: UIEdgeInsets(top: 20, left: 30, bottom: 0, right: 30))
        
        contentView.layoutIfNeeded()
        userImageView.makeRound()
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

    @objc func didTapLeftButton() {
        
        self.delegate?.didTapLeftButton()
    }
    
    @objc func didTapRightButton() {
        
        self.delegate?.didTapRightButton()
    }
    
    @objc func didTapFriend() {
        
        self.delegate?.didTapFriend()
    }
}
