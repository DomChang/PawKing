//
//  PhotoItemCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/19.
//

import UIKit

class PhotoItemCell: UICollectionViewCell {
    
    static let identifier = "\(PhotoItemCell.self)"
    
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.image = UIImage.asset(.Image_Placeholder_Paw)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(photoURL: URL) {
        
        contentView.addSubview(imageView)
        
        imageView.anchor(top: contentView.topAnchor,
                         leading: contentView.leadingAnchor,
                         bottom: contentView.bottomAnchor,
                         trailing: contentView.trailingAnchor)
        
        contentView.layoutIfNeeded()
        
        imageView.contentMode = .scaleAspectFill
        
        imageView.layer.cornerRadius = 5

        imageView.clipsToBounds = true
        
        imageView.kf.setImage(with: photoURL)
    }
}
