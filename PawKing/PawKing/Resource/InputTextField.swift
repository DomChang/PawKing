//
//  InputTextField.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/1.
//

import Foundation
import UIKit

class InputTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    func setup() {
        
        layer.cornerRadius = 4
        layer.borderColor = UIColor.DarkBlue?.cgColor
        layer.borderWidth = 0.5
        
    }

}
