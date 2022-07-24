//
//  FriendRequestCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/30.
//

import UIKit

protocol FriendRequestCellDelegate: AnyObject {
    
    func didTapAccept(from cell: FriendRequestCell)
    
    func didTapDeny(from cell: FriendRequestCell)
}

class FriendRequestCell: UITableViewCell {

    static let identifier = "\(FriendRequestCell.self)"
    
    var delegate: FriendRequestCellDelegate?
    
    let userImageView = UIImageView()
    
    let userNameLabel = UILabel()
    
    let acceptButton = UIButton()
    
    let denyButton = UIButton()
    
    var sender: User?

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
        
        acceptButton.isHidden = true
        
        denyButton.isHidden = true
        
        acceptButton.addTarget(self, action: #selector(didTapAcceptButton),
                               for: .touchUpInside)
        
        denyButton.addTarget(self, action: #selector(didTapDenyButton),
                               for: .touchUpInside)
    }
    
    private func styleObject() {
        
        userNameLabel.textColor = .BattleGrey
        userNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        userImageView.contentMode = .scaleAspectFill
        
        acceptButton.setTitle("Accept", for: .normal)
        acceptButton.backgroundColor = .CoralOrange
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        acceptButton.layer.cornerRadius =  5
        
        denyButton.setTitle("Deny", for: .normal)
        denyButton.layer.borderWidth = 1
        denyButton.layer.borderColor = UIColor.BattleGrey?.cgColor
        denyButton.backgroundColor = .white
        denyButton.setTitleColor(.BattleGrey, for: .normal)
        denyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        denyButton.layer.cornerRadius =  5
    }
    
    private func layout() {
        
        userImageView.constrainWidth(constant: 40)
        userImageView.constrainHeight(constant: 40)
        
        let hStackView = UIStackView(arrangedSubviews: [userImageView, userNameLabel])
        
        hStackView.distribution = .fill
        hStackView.axis = .horizontal
        hStackView.spacing = 8
        
        contentView.addSubview(hStackView)
        contentView.addSubview(acceptButton)
        contentView.addSubview(denyButton)
        
        hStackView.anchor(top: contentView.topAnchor,
                          leading: contentView.leadingAnchor,
                          bottom: contentView.bottomAnchor,
                          padding: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 8))
        
        acceptButton.anchor(leading: hStackView.trailingAnchor,
                            centerY: contentView.centerYAnchor,
                            width: 65,
                            height: 30,
                            padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        
        denyButton.anchor(leading: acceptButton.trailingAnchor,
                          trailing: contentView.trailingAnchor,
                          centerY: contentView.centerYAnchor,
                          width: 60,
                          height: 30,
                          padding: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 16))
        
        userImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        acceptButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        denyButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        hStackView.layoutIfNeeded()
        
        userImageView.makeRound()
        
        userImageView.clipsToBounds = true
    }
    
    func configureCell(sender: User) {
        
        self.sender = sender
        
        let userUrl = URL(string: sender.userImage)
        
        userImageView.kf.setImage(with: userUrl)
        
        userNameLabel.text = sender.name
        
        acceptButton.isHidden = false
        
        denyButton.isHidden = false
        
    }
    
    @objc func didTapAcceptButton() {
        
        acceptButton.isEnabled = false
        
        self.delegate?.didTapAccept(from: self)
    }
    
    @objc func didTapDenyButton() {
        
        denyButton.isEnabled = false
        
        self.delegate?.didTapDeny(from: self)
    }

}
