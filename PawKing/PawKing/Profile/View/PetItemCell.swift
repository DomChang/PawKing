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

    var photoURL: URL? {
        
        didSet {
            configureCell()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .clear
        configureCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell() {
        
        contentView.addSubview(imageView)
        
        self.layoutIfNeeded()
        
        imageView.makeRound()

        imageView.clipsToBounds = true
        
        imageView.kf.setImage(with: photoURL)
        
        imageView.anchor(top: contentView.topAnchor,
                         leading: contentView.leadingAnchor,
                         bottom: contentView.bottomAnchor,
                         trailing: contentView.trailingAnchor)
    }
}
