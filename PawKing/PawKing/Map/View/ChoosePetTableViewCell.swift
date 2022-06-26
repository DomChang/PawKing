//
//  ChoosePetTableViewCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/19.
//

import UIKit

class ChoosePetTableViewCell: UITableViewCell {
    
    static let identifier = "\(PetConfigCell.self)"
    
    let petImageView = UIImageView()
    
    let petNameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
    
        styleObject()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func styleObject () {
        
        contentView.backgroundColor = .YB1
        
        petImageView.layer.borderColor = UIColor.white.cgColor
        petImageView.layer.borderWidth = 2
        
        petNameLabel.textColor = .LightBlack
        petNameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
    
    private func layout() {
        
        petImageView.constrainWidth(constant: 80)
        petImageView.constrainHeight(constant: 80)
        
        let hStack = UIStackView(arrangedSubviews: [petImageView, petNameLabel])
        
        hStack.axis = .horizontal
        hStack.distribution = .fill
        hStack.spacing = 25
        
        contentView.addSubview(hStack)
        
        hStack.anchor(top: contentView.topAnchor,
                      leading: contentView.leadingAnchor,
                      bottom: contentView.bottomAnchor,
                      trailing: contentView.trailingAnchor,
                      padding: UIEdgeInsets(top: 20, left: 50, bottom: 20, right: 20))
        
        petImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        hStack.layoutIfNeeded()
        
        petImageView.makeRound()
        
        petImageView.clipsToBounds = true
    }
    
    func configureCell(pet: Pet) {
        
        let imageUrl = URL(string: pet.petImage)
        
        petImageView.kf.setImage(with: imageUrl)
        
        petNameLabel.text = pet.name
    }
    
}
