//
//  PetItemCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/19.
//

import UIKit

class PetItemCell: UICollectionViewCell {
    
    static let identifier = "\(PetItemCell.self)"
    
    let imageView = UIImageView()
    
    let backBorderView = UIView()

    var photoURL: URL? {
        
        didSet {
            configureCell()
        }
    }
    
//    override var isSelected: Bool {
//        
//        didSet {
//            
//            if isSelected {
//                
//                imageView.layer.borderColor = UIColor.black.cgColor
//                imageView.layer.borderWidth = 2
//            } else {
//                
//                imageView.layer.borderWidth = 0
//            }
//        }
//    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .clear
        
        backBorderView.backgroundColor = .Orange1
        
        backBorderView.isHidden = true
        
        configureCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell() {
        
        contentView.addSubview(backBorderView)
        contentView.addSubview(imageView)
        
        imageView.contentMode = .scaleAspectFill
        
        imageView.anchor(top: contentView.topAnchor,
                         leading: contentView.leadingAnchor,
                         bottom: contentView.bottomAnchor,
                         trailing: contentView.trailingAnchor,
                         padding: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
        
        backBorderView.anchor(top: contentView.topAnchor,
                              leading: contentView.leadingAnchor,
                              bottom: contentView.bottomAnchor,
                              trailing: contentView.trailingAnchor)
        
        contentView.layoutIfNeeded()
        
        imageView.makeRound()
        
        backBorderView.makeRound()

        imageView.clipsToBounds = true
        
        imageView.kf.setImage(with: photoURL)
    }
}
