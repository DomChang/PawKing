//
//  SearchResultCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/23.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    static let identifier = "\(SearchResultCell.self)"
    
    let userImageView = UIImageView()
    
    let userNameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
        styleObject()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        self.selectionStyle = .none
    }
    
    private func styleObject() {
        
        userNameLabel.textColor = .brown
        userNameLabel.font = UIFont.systemFont(ofSize: 18)
        
        userImageView.contentMode = .scaleAspectFill
    }
    
    private func layout() {
        
        userImageView.constrainWidth(constant: 30)
        userImageView.constrainHeight(constant: 30)
        
        let hStackView = UIStackView(arrangedSubviews: [userImageView, userNameLabel])
        
        hStackView.distribution = .fill
        hStackView.axis = .horizontal
        hStackView.spacing = 8
        
        contentView.addSubview(hStackView)
        
        hStackView.anchor(top: contentView.topAnchor,
                          leading: contentView.leadingAnchor,
                          bottom: contentView.bottomAnchor,
                          trailing: contentView.trailingAnchor,
                          padding: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        
        userImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        hStackView.layoutIfNeeded()
        
        userImageView.makeRound()
        
        userImageView.clipsToBounds = true
    }
    
    func configureCell(user: User) {
        
        let userUrl = URL(string: user.userImage)
        
        userImageView.kf.setImage(with: userUrl)
        
        userNameLabel.text = user.name
        
    }
}
