//
//  InputCommentView.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/30.
//

import UIKit

class InputCommentView: UIView {
    
    let userImageView = UIImageView()
    
    let userInputTextView = InputTextView()

    let sendButton = UIButton()

    private let inputSeperatorLine = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        userInputTextView.isScrollEnabled = false
        userInputTextView.placeholder = "Enter Comment"
        userInputTextView.delegate = self
    }
    
    private func style() {
        
        inputSeperatorLine.backgroundColor = .lightGray
        
        userImageView.contentMode = .scaleAspectFill
        
        userInputTextView.backgroundColor = .white
        userInputTextView.font = UIFont.systemFont(ofSize: 18)
        
        sendButton.layer.cornerRadius = 3
        sendButton.setTitle("Submit", for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
        backgroundColor = .white
        
        sendButtonDisable()
    }
    
    private func layout() {
        
        addSubview(inputSeperatorLine)
        addSubview(userImageView)
        addSubview(userInputTextView)
        addSubview(sendButton)
        
        userImageView.anchor(top: topAnchor,
                             leading: leadingAnchor,
                             width: 40,
                             height: 40,
                             padding: UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 0))
        
        userInputTextView.anchor(top: topAnchor,
                                 leading: userImageView.trailingAnchor,
                                 bottom: bottomAnchor,
                                  trailing: sendButton.leadingAnchor,
                                 padding: UIEdgeInsets(top: 8, left: 10, bottom: 10, right: 10))
        
        sendButton.anchor(trailing: trailingAnchor,
                          centerY: centerYAnchor,
                          width: 60,
                          height: 35,
                          padding: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 20))
        
        inputSeperatorLine.anchor(leading: leadingAnchor,
                                  bottom: topAnchor,
                                  trailing: trailingAnchor,
                                  height: 0.5)
        
        userImageView.clipsToBounds = true
    }
    
    func sendButtonEnable() {
        
        sendButton.isEnabled = true
        sendButton.backgroundColor = .CoralOrange
    }
    
    func sendButtonDisable() {
        
        sendButton.isEnabled = false
        sendButton.backgroundColor = .MainGray
    }
}

extension InputCommentView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView == userInputTextView else { return }
        
        if textView.text.isEmpty {
            
            sendButtonDisable()
        } else {
            
            sendButtonEnable()
        }
    }
}
