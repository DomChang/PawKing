//
//  EditPetCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/3.
//

import UIKit

class EditPetCell: UITableViewCell {
    
    static let identifier = "\(EditPetCell.self)"
    
    let petImageView = UIImageView()
    
    let petNameLabel = UILabel()

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
        
        selectionStyle = .none
    }
    
    private func styleObject() {
        
        contentView.backgroundColor = .white
        
        petImageView.layer.borderColor = UIColor.white.cgColor
        petImageView.layer.borderWidth = 2
        petImageView.contentMode = .scaleAspectFill
        
        petNameLabel.textColor = .DarkBlue
        petNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    private func layout() {
        
        petImageView.constrainWidth(constant: 50)
        petImageView.constrainHeight(constant: 50)
        
        let hStack = UIStackView(arrangedSubviews: [petImageView, petNameLabel])
        
        hStack.axis = .horizontal
        hStack.distribution = .fill
        hStack.spacing = 25
        
        contentView.addSubview(hStack)
        
        hStack.anchor(top: contentView.topAnchor,
                      leading: contentView.leadingAnchor,
                      bottom: contentView.bottomAnchor,
                      trailing: contentView.trailingAnchor,
                      padding: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        
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
