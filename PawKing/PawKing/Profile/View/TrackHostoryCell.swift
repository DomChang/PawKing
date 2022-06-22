//
//  TrackHostoryCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/19.
//

import UIKit

class TrackHostoryCell: UICollectionViewCell {
    
    static let identifier = "\(TrackHostoryCell.self)"
    
    let petImageView = UIImageView()
    
    let petNameLabel = UILabel()
    
    let dateLabel = UILabel()
    
    var petPhotoURL: URL? {
        didSet {
            configureCell()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell() {
        
        contentView.addSubview(dateLabel)
        contentView.addSubview(petImageView)
        contentView.addSubview(petNameLabel)
        
        dateLabel.anchor(top: contentView.topAnchor,
                         leading: contentView.leadingAnchor,
                         trailing: contentView.trailingAnchor,
                         height: 16,
                         padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        
        petImageView.anchor(top: dateLabel.bottomAnchor,
                            centerX: contentView.centerXAnchor,
                            width: 50,
                            height: 50,
                            padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        
        petNameLabel.anchor(top: petImageView.bottomAnchor,
                            leading: contentView.leadingAnchor,
                            trailing: contentView.trailingAnchor,
                            height: 16,
                            padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
        
        contentView.layer.cornerRadius = contentView.frame.width / 4
        
        contentView.layoutIfNeeded()
        
        contentView.backgroundColor = .O1
        
        dateLabel.textColor = .black
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textAlignment = .center
        
        petImageView.kf.setImage(with: petPhotoURL)
        
        petImageView.makeRound()
        petImageView.clipsToBounds = true
        
        petNameLabel.textColor = .black
        petNameLabel.font = UIFont.systemFont(ofSize: 14)
        petNameLabel.textAlignment = .center
    }
}
