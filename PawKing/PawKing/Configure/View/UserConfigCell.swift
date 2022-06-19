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
    
    let photoButton = UIButton()
    
    let userNameTextfield = UITextField()
    
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
        
        photoButton.isUserInteractionEnabled = true
        
        photoButton.addTarget(self, action: #selector(didTapPhotoButton),
                                  for: .touchUpInside)
        
//        userNameTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)),
//                                  for: .editingChanged)
        
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }
    
    func styleObject() {
        
        photoButton.setImage(UIImage.asset(.Image_Placeholder), for: .normal)
        
        userNameTextfield.layer.borderColor = UIColor.G1?.cgColor
        userNameTextfield.layer.borderWidth = 1
        
        descriptionTextView.layer.borderColor = UIColor.G1?.cgColor
        descriptionTextView.layer.borderWidth = 1
        
        nextButton.setTitle("Next", for: .normal)
        nextButton.backgroundColor = .O1
    }
    
    func layout() {
        
        contentView.addSubview(photoButton)
        contentView.addSubview(userNameTextfield)
        contentView.addSubview(descriptionTextView)
        contentView.addSubview(nextButton)
        
        photoButton.anchor(top: contentView.topAnchor,
                           centerX: contentView.centerXAnchor,
                           width: 150,
                           height: 150,
                           padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        
        userNameTextfield.anchor(top: photoButton.bottomAnchor,
                                 leading: contentView.leadingAnchor,
                                 trailing: contentView.trailingAnchor,
                                 height: 30,
                                 padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
        
        descriptionTextView.anchor(top: userNameTextfield.bottomAnchor,
                                   leading: userNameTextfield.leadingAnchor,
                                   trailing: userNameTextfield.trailingAnchor,
                                   height: 200,
                                   padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        
        nextButton.anchor(top: descriptionTextView.bottomAnchor,
                          leading: contentView.leadingAnchor,
                          trailing: contentView.trailingAnchor,
                          height: 50,
                          padding: UIEdgeInsets(top: 20, left: 30, bottom: 0, right: 30))
    }
    
    @objc func didTapPhotoButton() {
        
        self.delegate?.didTapPhoto()
    }
    
    @objc func didTapNext() {
        
        self.delegate?.didTapNext(from: self)
    }
    
//    @objc func textFieldDidChange(_ textField: UITextField) {
//
//        guard textField == userNameTextfield else { return }
//
//        self.delegate?.textFieldDidChange(From: textField)
//    }
}

extension UserConfigCell: UITextViewDelegate {
    
}
