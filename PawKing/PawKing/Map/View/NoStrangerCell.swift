//
//  NoStrangerCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/26.
//

import UIKit

class NoStrangerCell: UICollectionViewCell {

    static let identifier = "\(NoStrangerCell.self)"
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func style() {
        
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        
        contentView.backgroundColor = .BattleGreyLight
        
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .LightBlack
        label.text = "No new friends nearby."
    }
    
    func layout() {
        
        contentView.addSubview(label)
        
        label.anchor(leading: contentView.leadingAnchor,
                     trailing: contentView.trailingAnchor,
                     centerY: contentView.centerYAnchor,
                     padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
}
