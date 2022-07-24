//
//  UserConfigCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/18.
//

import UIKit

protocol UserConfigCellDelegate {
    
//    func textFieldDidChange(From textField: UITextField)
    
    func didTapPhoto()
    
    func didTapNext(from cell: UserConfigCell)
}

class UserConfigCell: UITableViewCell {
    
    static let identifier = "\(UserConfigCell.self)"
    
    var delegate: UserConfigCellDelegate?
    
    let userImageView = UIImageView()
    
    private let nameTitleLabel = UILabel()
    
    let userNameTextfield = InputTextField()
    
    let descriptionTextView = UITextView()
    
    private let nextButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
        styleObject()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        userImageView.isUserInteractionEnabled = true
        
        userImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapPhoto)))
        
        nameTitleLabel.text = "User Name"
        nameTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        nameTitleLabel.textColor = .BattleGrey
        
//        userNameTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)),
//                                  for: .editingChanged)
        
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }
    
    func styleObject() {
        
        userImageView.image = UIImage.asset(.Image_Placeholder_Human)
        userImageView.contentMode = .scaleAspectFill
        
        userNameTextfield.layer.borderColor = UIColor.MainGray?.cgColor
        userNameTextfield.layer.borderWidth = 1
        
        descriptionTextView.layer.borderColor = UIColor.MainGray?.cgColor
        descriptionTextView.layer.borderWidth = 1
        
        nextButton.setTitle("Next", for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nextButton.backgroundColor = .CoralOrange
        nextButton.layer.cornerRadius = 4
    }
    
    func layout() {
        
        contentView.addSubview(userImageView)
        contentView.addSubview(nameTitleLabel)
        contentView.addSubview(userNameTextfield)
//        contentView.addSubview(descriptionTextView)
        contentView.addSubview(nextButton)
        
        userImageView.anchor(top: contentView.topAnchor,
                           centerX: contentView.centerXAnchor,
                           width: 150,
                           height: 150,
                           padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        
        nameTitleLabel.anchor(top: userImageView.bottomAnchor,
                              leading: contentView.leadingAnchor,
                              trailing: contentView.trailingAnchor,
                              height: 20,
                              padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 0))
        
        userNameTextfield.anchor(top: nameTitleLabel.bottomAnchor,
                                 leading: nameTitleLabel.leadingAnchor,
                                 trailing: contentView.trailingAnchor,
                                 height: 40,
                                 padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 20))
       
//        descriptionTextView.anchor(top: userNameTextfield.bottomAnchor,
//                                   leading: userNameTextfield.leadingAnchor,
//                                   trailing: userNameTextfield.trailingAnchor,
//                                   height: 200,
//                                   padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        
        nextButton.anchor(top: userNameTextfield.bottomAnchor,
                          leading: userNameTextfield.leadingAnchor,
                          trailing: userNameTextfield.trailingAnchor,
                          height: 40,
                          padding: UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0))
        
        userImageView.layoutIfNeeded()
        userImageView.makeRound()
        userImageView.clipsToBounds = true
    }
    
    @objc func didTapPhoto() {
        
        self.delegate?.didTapPhoto()
    }
    
    @objc func didTapNext() {
        
        self.delegate?.didTapNext(from: self)
    }
    
    func nextButtonEnable() {
        
        nextButton.isEnabled = true
        nextButton.backgroundColor = .CoralOrange
    }
    
    func nextButtonDisable() {
        
        nextButton.isEnabled = false
        nextButton.backgroundColor = .MainGray
    }
}
