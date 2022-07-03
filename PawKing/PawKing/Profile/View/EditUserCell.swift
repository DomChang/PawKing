//
//  EditUserCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/3.
//

import UIKit

protocol EditUserCellDelegate {
    
    func didEditUserName(to userName: String)
}

class EditUserCell: UITableViewCell {
    
    static let identifier = "\(EditUserCell.self)"
    
    var delegate: EditUserCellDelegate?
    
    private let userNameTextField = InputTextField()
    
    private let confirmButton = UIButton()

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
        
        userNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        
        confirmButtonDisable()
    }
    
    private func styleObject() {
        
        userNameTextField.placeholder = "UserName"
        userNameTextField.layer.borderWidth = 0
        
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.layer.cornerRadius = 4
    }
    
    private func layout() {
        
        contentView.addSubview(userNameTextField)
        contentView.addSubview(confirmButton)
        
        userNameTextField.anchor(top: contentView.topAnchor,
                                 leading: contentView.leadingAnchor,
                                 bottom: contentView.bottomAnchor,
                                 height: 40,
                                 padding: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        
        confirmButton.anchor(leading: userNameTextField.trailingAnchor,
                             trailing: contentView.trailingAnchor,
                             centerY: userNameTextField.centerYAnchor,
                             width: 80,
                             height: 40,
                             padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20))
    }
    
    func configureCell(user: User) {
        
        userNameTextField.text = user.name
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        guard textField == userNameTextField else { return }

        if textField.hasText {

            confirmButtonEnable()

        } else {
            
            confirmButtonDisable()
        }
    }
    
    @objc func didTapConfirm() {
         
        guard let userNameText = userNameTextField.text else { return }
        
        self.delegate?.didEditUserName(to: userNameText)
    }
    
    func confirmButtonEnable() {
        
        confirmButton.backgroundColor = .Orange1
        confirmButton.isEnabled = true
    }
    
    func confirmButtonDisable() {
        
        confirmButton.backgroundColor = .Gray1
        confirmButton.isEnabled = false
    }
}
