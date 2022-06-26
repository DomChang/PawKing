//
//  PetItemBackReusableView.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/26.
//

import UIKit

class PetItemBackReusableView: UICollectionReusableView {
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .YB1
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}
