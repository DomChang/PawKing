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
    
        backgroundColor = .BattleGrey
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        
        backView.backgroundColor = .white
        
        backView.layer.cornerRadius = 20
        
        backView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        addSubview(backView)
//        addSubview(gridIconImageView)
        
//        gridIconImageView.image = UIImage.asset(.Icons_30px_Grid_fill)
        
//        backView.anchor(top: bottomAnchor,
//                        leading: leadingAnchor,
//                        bottom: bottomAnchor,
//                        trailing: trailingAnchor,
//                        padding: UIEdgeInsets(top: -40, left: 0, bottom: 0, right: 0))
        
//        gridIconImageView.anchor(centerY: backView.centerYAnchor,
//                                 centerX: centerXAnchor,
//                                 width: 30,
//                                 height: 30)
    }
}
