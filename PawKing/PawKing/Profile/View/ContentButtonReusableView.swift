//
//  ContentButtonReusableView.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/4.
//

import UIKit

class ContentButtonReusableView: UICollectionReusableView {
    
    private let backView = UIView()
        
    override init(frame: CGRect) {
            super.init(frame: frame)
        
        backgroundColor = .BattleGrey
        
        layout()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        
        backView.backgroundColor = .white
        
        addSubview(backView)
        
        backView.anchor(top: topAnchor,
                        leading: leadingAnchor,
                        bottom: bottomAnchor,
                        trailing: trailingAnchor)
        
        backView.layer.cornerRadius = 20
        backView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}
