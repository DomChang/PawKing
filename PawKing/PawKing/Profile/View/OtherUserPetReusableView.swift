//
//  OtherUserPetReusableView.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/5.
//

import UIKit

class OtherUserPetReusableView: UICollectionReusableView {
    
    private let backView = UIView()
    
    private let gridIconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        backgroundColor = .white
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        
        backView.backgroundColor = .BattleGrey
        
        addSubview(backView)
        
        backView.anchor(top: topAnchor,
                        leading: leadingAnchor,
                        bottom: bottomAnchor,
                        trailing: trailingAnchor)
    }
}
