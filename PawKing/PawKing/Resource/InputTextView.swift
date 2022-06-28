//
//  InputTextView.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/28.
//

import UIKit

class InputTextView: UITextView {
    
    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    fileprivate let placeholderLabel = UILabel()
    
    func showPlaceholderLabel() {
        placeholderLabel.isHidden = false
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange),
                                               name: UITextView.textDidChangeNotification, object: nil)
        
        placeholderLabel.textColor = .lightGray
        
        addSubview(placeholderLabel)
        
        placeholderLabel.anchor(top: topAnchor,
                                leading: leadingAnchor,
                                bottom: bottomAnchor,
                                trailing: trailingAnchor,
                                padding: UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 0))
    }

    @objc func handleTextChange() {
        placeholderLabel.isHidden = !self.text.isEmpty
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
