//
//  PetItemCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/19.
//

import UIKit

class PetItemCell: UICollectionViewCell {
    
    static let identifier = "\(PetItemCell.self)"
    
    private let imageView = UIImageView()
    
    private let frontView = UIView()
    
    private let petNameLabel = UILabel()
    
    private let backBorderView = UIView()
    
    var selectState = false {
        
        didSet {
            
            if selectState {
                
                isCellSelect()
                
            } else {
                
                notCellSelect()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        notCellSelect()
    }
    
    private func style() {
        
        contentView.backgroundColor = .clear
        
        backBorderView.backgroundColor = .white
        
        frontView.backgroundColor = .black.withAlphaComponent(0.3)
        
        petNameLabel.textColor = .white
        petNameLabel.textAlignment = .center
        petNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        petNameLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func layout() {
        
        contentView.addSubview(backBorderView)
        contentView.addSubview(imageView)
        contentView.addSubview(frontView)
        contentView.addSubview(petNameLabel)
        
        imageView.contentMode = .scaleAspectFill
        
        backBorderView.anchor(top: contentView.topAnchor,
                              leading: contentView.leadingAnchor,
                              bottom: contentView.bottomAnchor,
                              trailing: contentView.trailingAnchor)
        
        imageView.anchor(top: contentView.topAnchor,
                         leading: contentView.leadingAnchor,
                         bottom: contentView.bottomAnchor,
                         trailing: contentView.trailingAnchor,
                         padding: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
        
        frontView.anchor(top: imageView.topAnchor,
                         leading: imageView.leadingAnchor,
                         bottom: imageView.bottomAnchor,
                         trailing: imageView.trailingAnchor)
        
        petNameLabel.anchor(leading: imageView.leadingAnchor,
                            trailing: imageView.trailingAnchor,
                            centerY: imageView.centerYAnchor,
                            padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
        
        contentView.layoutIfNeeded()
        
        imageView.makeRound()
        
        frontView.makeRound()
        
        backBorderView.makeRound()

        imageView.clipsToBounds = true
        
    }
    
    func configureCell(pet: Pet) {
        
        let imageUrl = URL(string: pet.petImage)
        
        imageView.kf.setImage(with: imageUrl)
        
        petNameLabel.text = pet.name
    }
    
    private func isCellSelect() {
        
        imageView.layer.borderWidth = 2
        
        imageView.layer.borderColor = UIColor.BattleGrey?.cgColor
        
        backBorderView.isHidden = false
        
        frontView.isHidden = false
        
        petNameLabel.isHidden = false
    }
    
    private func notCellSelect() {
        
        backBorderView.isHidden = true
        
        frontView.isHidden = true
        
        petNameLabel.isHidden = true
        
        imageView.layer.borderWidth = 0
        
        backBorderView.isHidden = true
    }
}
