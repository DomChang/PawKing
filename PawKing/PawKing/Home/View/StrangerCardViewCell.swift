//
//  StrangerCardViewCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/17.
//

import UIKit
import Kingfisher
import SwiftUI

class StrangerCardViewCell: UICollectionViewCell {
    
    static let identifier = "\(StrangerCardViewCell.self)"
    
    private let petImageView = UIImageView()
    
    private let nameLabel = UILabel()
    
    private let genderIconView = UIImageView()
    
    private let ageIconView = UIImageView()
    
    private let genderLabel = UILabel()
    
    private let ageLabel = UILabel()
    
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
        
        petImageView.contentMode = .scaleAspectFill
        petImageView.layer.borderWidth = 2
        petImageView.layer.borderColor = UIColor.white.cgColor
        
        nameLabel.textColor = .LightBlack
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        nameLabel.adjustsFontSizeToFitWidth = true
        
        genderIconView.image = UIImage.asset(.Icons_24px_Gender)
        
        genderLabel.textColor = .white
        genderLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        ageIconView.image = UIImage.asset(.Icons_24px_Age)
        
        ageLabel.textColor = .white
        ageLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        ageLabel.adjustsFontSizeToFitWidth = true
    }
    
    func layout() {
        
        contentView.addSubview(petImageView)
        
        let hGenderStack = UIStackView(arrangedSubviews: [genderIconView, genderLabel])
        
        genderIconView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        genderIconView.constrainWidth(constant: 20)
        genderIconView.constrainHeight(constant: 20)
        
        hGenderStack.distribution = .fill
        hGenderStack.spacing = 8
        hGenderStack.axis = .horizontal
        
        let hAgeStack = UIStackView(arrangedSubviews: [ageIconView, ageLabel])
        
        ageIconView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        ageIconView.constrainWidth(constant: 20)
        ageIconView.constrainHeight(constant: 20)
        
        hAgeStack.distribution = .fill
        hAgeStack.spacing = 8
        hAgeStack.axis = .horizontal

        let vStack = UIStackView(arrangedSubviews: [nameLabel, hGenderStack, hAgeStack])
        
        contentView.addSubview(vStack)
        
        vStack.distribution = .fill
        vStack.spacing = 8
        vStack.axis = .vertical
        
        petImageView.anchor(leading: contentView.leadingAnchor,
                            centerY: contentView.centerYAnchor,
                            width: contentView.frame.height * 0.6,
                            height: contentView.frame.height * 0.6,
                            padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0))
        
        vStack.anchor(top: petImageView.topAnchor,
                      leading: petImageView.trailingAnchor,
                      trailing: contentView.trailingAnchor,
                      padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        
        contentView.layoutIfNeeded()
        
        petImageView.makeRound()
        
        petImageView.clipsToBounds = true
    }
    
    func configuerCell(with pet: Pet) {
        
        let url = URL(string: pet.petImage)
        
        petImageView.kf.setImage(with: url)
        
        nameLabel.text = pet.name
        
        genderLabel.text = "\(pet.gender)"
        
        let date = pet.birthday.dateValue()

        let age = date.displayTimeInAgeStyle()
        
        ageLabel.text = "\(age)"
    }
}
