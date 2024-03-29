//
//  PhotoPostCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/22.
//

import UIKit

@objc protocol PhotoPostCellDelegate: AnyObject {
    
    func didTapLike(for cell: PhotoPostCell, like: Bool)
    
    func didTapAction()
    
    @objc optional func didTapUser()
    
    func didTapLikeUsers()
}

class PhotoPostCell: UITableViewCell {
    
    static let identifier = "\(PhotoItemCell.self)"
    
    weak var delegate: PhotoPostCellDelegate?
    
    let petImageView = UIImageView()
    
    let petNameLabel = UILabel()
    
    let ownerLabel = UILabel()
    
    let settingButton = UIButton()
    
    let photoImageView = UIImageView()
    
    let backView = UIView()
    
    let likeButton = UIButton()
    
    let likeNumLabel = UILabel()
    
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
        
        petImageView.isUserInteractionEnabled = true
        petImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapUser)))
        
        petNameLabel.isUserInteractionEnabled = true
        petNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapUser)))
        
        nameContentLabel.isUserInteractionEnabled = true
        nameContentLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapUser)))
        
        likeNumLabel.isUserInteractionEnabled = true
        likeNumLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapLikeLabel)))
        
        photoImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLikeButton))
        tap.numberOfTapsRequired = 2
        
        photoImageView.addGestureRecognizer(tap)
        
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        
        likeButton.isHidden = true
        
        settingButton.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
    }
    
    private func styleObject() {
        
        contentView.backgroundColor = .BattleGrey
        
        petImageView.contentMode = .scaleAspectFill
        petImageView.layer.borderWidth = 1
        petImageView.layer.borderColor = UIColor.white.cgColor
        
        photoImageView.contentMode = .scaleAspectFill
        
        backView.backgroundColor = .white
        backView.layer.cornerRadius = 20
        backView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        petNameLabel.textAlignment = .left
        petNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        petNameLabel.textColor = .white
        
        ownerLabel.textAlignment = .left
        ownerLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        ownerLabel.textColor = .white
        
        settingButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        settingButton.tintColor = .white
        
        likeButton.setImage(UIImage(systemName: "suit.heart",
                                    withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        
        likeButton.setImage(UIImage(systemName: "suit.heart.fill",
                                    withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .selected)
        
        likeButton.tintColor = .BattleGrey
        
        likeNumLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        likeNumLabel.textColor = .BattleGrey
        
        nameContentLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        nameContentLabel.textColor = .BattleGrey
        
        contentLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        contentLabel.textColor = .LightBlack
        
        timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        timeLabel.textColor = .MainGray
        timeLabel.textAlignment = .left
    }
    
    private func layout() {
        
        settingButton.constrainWidth(constant: 30)
        settingButton.constrainHeight(constant: 30)
        
        let vOwnerStack = UIStackView(arrangedSubviews: [petNameLabel, ownerLabel])
        vOwnerStack.axis = .vertical
        vOwnerStack.distribution = .fillProportionally
        vOwnerStack.spacing = 8
        
        let petInfoStack = UIStackView(arrangedSubviews: [vOwnerStack, settingButton])
        petInfoStack.axis = .horizontal
        petInfoStack.distribution = .fill
        petInfoStack.spacing = 15
        
        petNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let infoStack = UIStackView(arrangedSubviews: [likeButton, likeNumLabel])
        infoStack.axis = .horizontal
        infoStack.distribution = .fill
        infoStack.spacing = 8
        
        likeButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let contentBodyStack = UIStackView(arrangedSubviews:
                                            [nameContentLabel, contentLabel])
        contentBodyStack.axis = .horizontal
        contentBodyStack.distribution = .fill
        contentBodyStack.spacing = 8
        
        nameContentLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let vStack = UIStackView(arrangedSubviews: [contentBodyStack, timeLabel])
        vStack.axis = .vertical
        vStack.distribution = .fill
        vStack.spacing = 8
        
        contentView.addSubview(petImageView)
        contentView.addSubview(petInfoStack)
        contentView.addSubview(photoImageView)
        contentView.addSubview(backView)
        contentView.addSubview(infoStack)
        contentView.addSubview(vStack)
        
        petImageView.anchor(top: contentView.topAnchor,
                            leading: contentView.leadingAnchor,
                            width: 40,
                            height: 40,
                            padding: UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 0))
        
        petInfoStack.anchor(top: petImageView.topAnchor,
                            leading: petImageView.trailingAnchor,
                            bottom: photoImageView.topAnchor,
                            trailing: contentView.trailingAnchor,
                            height: 40,
                            padding: UIEdgeInsets(top: 0, left: 16, bottom: 10, right: 20))
        
        photoImageView.anchor(leading: contentView.leadingAnchor,
                              trailing: contentView.trailingAnchor,
                              height: UIScreen.main.bounds.width + 20,
                             padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        
        backView.anchor(top: photoImageView.bottomAnchor,
                        leading: contentView.leadingAnchor,
                        bottom: contentView.bottomAnchor,
                        trailing: contentView.trailingAnchor,
                        padding: UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0))
        
        infoStack.anchor(top: backView.topAnchor,
                         leading: contentView.leadingAnchor,
                         trailing: contentView.trailingAnchor,
                         height: 30,
                         padding: UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 10))
        
        vStack.anchor(top: likeButton.bottomAnchor,
                            leading: likeButton.leadingAnchor,
                            bottom: contentView.bottomAnchor,
                            trailing: contentView.trailingAnchor,
                             padding: UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 20))
        
        contentView.layoutIfNeeded()
        petImageView.makeRound()
        petImageView.clipsToBounds = true
        photoImageView.clipsToBounds = true
    }
    
    func configureCell(user: User, pet: Pet, post: Post, likeCount: Int, isLike: Bool) {
        
        let petUrl = URL(string: pet.petImage)
        
        petImageView.kf.setImage(with: petUrl)
        
        petNameLabel.text = pet.name
        
        ownerLabel.text = "by \(user.name)"
        
        let photoUrl = URL(string: post.photo)
        
        photoImageView.kf.setImage(with: photoUrl)
        
        if likeCount == 0 {
            
            likeNumLabel.text = ""
            
        } else if likeCount == 1 {
            
            likeNumLabel.text = "\(likeCount) like"
        } else {
            
            likeNumLabel.text = "\(likeCount) likes"
        }
        
        if isLike {
            
            didLikePost()
        } else {
            
            notLikePost()
        }
        
        nameContentLabel.text = user.name
        
        contentLabel.text = post.caption
        
        timeLabel.text = post.createdTime.dateValue().displayTimeInSocialMediaStyle()
        
        likeButton.isHidden = false
    }
    
    @objc func didTapLikeButton() {
        
        likeButton.isSelected = !likeButton.isSelected
        
        self.delegate?.didTapLike(for: self, like: likeButton.isSelected)
    }
    
    func didLikePost() {
        
        likeButton.tintColor = .CoralOrange
        
        likeButton.isSelected = true
    }
    
    func notLikePost() {
        
        likeButton.tintColor = .BattleGrey
        
        likeButton.isSelected = false
    }
    
    @objc func didTapUser() {
        
        self.delegate?.didTapUser?()
    }
    
    @objc func didTapAction() {
        
        self.delegate?.didTapAction()
    }
    
    @objc func didTapLikeLabel() {
        
        self.delegate?.didTapLikeUsers()
    }
}
