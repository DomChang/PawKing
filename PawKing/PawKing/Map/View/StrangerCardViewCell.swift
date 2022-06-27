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
    
    let petImageView = UIImageView()
    
    let nameLabel = UILabel()
    
    let genderLabel = UILabel()
    
    let ageLabel = UILabel()
    
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
        contentView.backgroundColor = .Blue1
        
        petImageView.contentMode = .scaleAspectFill
        petImageView.layer.borderWidth = 2
        petImageView.layer.borderColor = UIColor.white.cgColor
        
        nameLabel.textColor = .LightBlack
        nameLabel.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        
        genderLabel.textColor = .white
        genderLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        ageLabel.textColor = .white
        ageLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    func layout() {
        
        contentView.addSubview(petImageView)

        let vStack = UIStackView(arrangedSubviews: [nameLabel, genderLabel, ageLabel])
        
        contentView.addSubview(vStack)
        
        vStack.distribution = .fill
        vStack.spacing = 8
        vStack.axis = .vertical
        
        petImageView.anchor(leading: contentView.leadingAnchor,
                            centerY: contentView.centerYAnchor,
                            width: contentView.frame.height * 0.6,
                            height: contentView.frame.height * 0.6,
                            padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0))
        
        vStack.anchor(top: contentView.topAnchor,
                      leading: petImageView.trailingAnchor,
                      bottom: contentView.bottomAnchor,
                      trailing: contentView.trailingAnchor,
                      padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        
        contentView.layoutIfNeeded()
        
        petImageView.makeRound()
        
        petImageView.clipsToBounds = true
    }
    
    func configuerCell(with pet: Pet) {
        
        let url = URL(string: pet.petImage)
        
        petImageView.kf.setImage(with: url)
        
        nameLabel.text = pet.name
        
        genderLabel.text = "Gender: \(PetGender.allCases[pet.gender].rawValue)"
        
        let date = pet.birthday.dateValue()
        let timeInterval = date.timeIntervalSinceNow
        let age = abs(Int(timeInterval / 31556926.0))
        
        ageLabel.text = "Age: \(age)"
    }
}
