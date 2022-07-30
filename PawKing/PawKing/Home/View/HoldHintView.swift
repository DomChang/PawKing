//
//  HoldHintView.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/30.
//

import UIKit

class HoldHintView: UIView {
    
    private let holdLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func style() {
        
        backgroundColor = .white
        
        holdLabel.text = "HOLD TO STOP"
        holdLabel.textColor = .CoralOrange
        holdLabel.font = .systemFont(ofSize: 16, weight: .heavy)
    }
    
    private func layout() {
        
        addSubview(holdLabel)
        
        holdLabel.anchor(centerY: centerYAnchor, centerX: centerXAnchor)
    }
}
