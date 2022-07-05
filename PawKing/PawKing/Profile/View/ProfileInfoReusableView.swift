//
//  ProfileInfoReusableView.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/27.
//

import UIKit

class ProfileInfoReusableView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        backgroundColor = .DarkBlue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
