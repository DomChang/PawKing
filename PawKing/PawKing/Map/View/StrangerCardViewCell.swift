//
//  StrangerCardViewCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/17.
//

import UIKit
import Kingfisher

class StrangerCardViewCell: UICollectionViewCell {
    
    static let identifier = "\(StrangerCardViewCell.self)"
    
    let petImageView = UIImageView()
    
    let nameLabel = UILabel()
    
    let genderLabel = UILabel()
    
    let infoLabel = UILabel()
    
    let verticalStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func style() {
        
        contentView.backgroundColor = .O1
        
        verticalStackView.distribution = .fill
        verticalStackView.spacing = 0
        verticalStackView.axis = .vertical
    }
    
    func layout() {
        
        contentView.addSubview(petImageView)
        contentView.addSubview(verticalStackView)
        
        petImageView.anchor(leading: contentView.leadingAnchor,
                            bottom: contentView.bottomAnchor,
                            centerY: contentView.centerYAnchor,
                            width: 75,
                            height: 75,
                            padding: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0))
        
        verticalStackView.anchor(top: contentView.topAnchor,
                                 leading: petImageView.trailingAnchor,
                                 bottom: contentView.bottomAnchor,
                                 trailing: contentView.trailingAnchor,
                                 padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0))
        
        verticalStackView.addArrangedSubview(nameLabel)
        verticalStackView.addArrangedSubview(genderLabel)
        verticalStackView.addArrangedSubview(infoLabel)
    }
    
    func configuerCell(with pet: Pet) {
        
        let url = URL(string: pet.petImage)
        
        petImageView.kf.setImage(with: url)
        
        nameLabel.text = pet.name
        
        genderLabel.text = "\(pet.gender)"
        
        var catFriendly = ""
        var childFriendly = ""
        var dogFriendly = ""
        
        if pet.personality.isCatFriendly {
            catFriendly = "親貓"
        }
        if pet.personality.isChildFriendly {
            childFriendly = "親小孩"
        }
        if pet.personality.isDogFriendly {
            dogFriendly = "親狗"
        }
        infoLabel.text = "\(dogFriendly) \(catFriendly) \(childFriendly)"
    }
}
