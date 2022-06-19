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
        
        styleObject()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func styleObject () {
        
        petImageView.layer.cornerRadius = 25
        
        petNameLabel.textColor = .black
        petNameLabel.font = UIFont.systemFont(ofSize: 18)
    }
    
    private func layout() {
        
        contentView.addSubview(petImageView)
        contentView.addSubview(petNameLabel)
        
        petImageView.anchor(leading: contentView.leadingAnchor,
                            centerY: contentView.centerYAnchor,
                            width: 50,
                            height: 50,
                            padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0))

        petNameLabel.anchor(leading: petImageView.trailingAnchor,
                            trailing: contentView.trailingAnchor,
                            centerY: contentView.centerYAnchor,
                            height: 20,
                            padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
    }
    
    func configureCell(pet: Pet) {
        
        let imageUrl = URL(string: pet.petImage)
        
        petImageView.kf.setImage(with: imageUrl)
        
        petNameLabel.text = pet.name
    }
    
}
