//
//  SettingCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/6.
//

import UIKit

class SettingCell: UITableViewCell {

    static let identifier = "\(SettingCell.self)"
    
    private let iconImageView = UIImageView()
    
    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        styleObject()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func styleObject() {
        
        selectionStyle = .none
        
        contentView.backgroundColor = .white
        
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    }
    
    private func layout() {
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        
        iconImageView.anchor(leading: contentView.leadingAnchor,
                             centerY: contentView.centerYAnchor,
                             width: 40,
                             height: 40,
                             padding: UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0))
        
        titleLabel.anchor(leading: iconImageView.trailingAnchor,
                          trailing: contentView.trailingAnchor,
                          centerY: contentView.centerYAnchor,
                          padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
    
    func configureCell(image: UIImage, title: String, highlight: Bool) {
        
        iconImageView.image = image
        
        titleLabel.text = title
        
        if highlight {
            
            titleLabel.textColor = .Orange1
        } else {
            
            titleLabel.textColor = .BattleGrey
        }
    }
}
