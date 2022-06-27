//
//  PetItemBackReusableView.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/26.
//

import UIKit

class PetItemBackReusableView: UICollectionReusableView {
    
    let topLine = UIView()
    
    let bottomLine = UIView()
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .Blue2
            
//            layout()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    private func layout() {
        
        topLine.backgroundColor = .Blue1
        bottomLine.backgroundColor = .Blue1
        
        addSubview(topLine)
        addSubview(bottomLine)
        
        topLine.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, height: 0.5)
        bottomLine.anchor(leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, height: 0.5)
    }
}
