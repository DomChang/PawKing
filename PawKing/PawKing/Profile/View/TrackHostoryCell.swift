//
//  TrackHostoryCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/19.
//

import UIKit
import MapKit

class TrackHostoryCell: UICollectionViewCell {
    
    static let identifier = "\(TrackHostoryCell.self)"
    
    private let petImageView = UIImageView()
    
    private let kmLabel = UILabel()

    private let distanceLabel = UILabel()
    
    private let dateLabel = UILabel()
    
    private let backView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        styleObject()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func styleObject() {
        
        contentView.backgroundColor = .white
        
        backView.backgroundColor = .BattleGreyUL
        backView.layer.cornerRadius = 5
        
        petImageView.contentMode = .scaleAspectFill
        petImageView.clipsToBounds = true
        
        dateLabel.textColor = .BattleGrey
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        dateLabel.textAlignment = .center
        
        kmLabel.textColor = .BattleGrey
        kmLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        kmLabel.textAlignment = .right
        kmLabel.text = "KM"
        
        distanceLabel.textColor = .BattleGrey
        distanceLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        distanceLabel.textAlignment = .center
    }
    
    private func layout() {
        
        contentView.addSubview(backView)
        contentView.addSubview(petImageView)
        backView.addSubview(distanceLabel)
        backView.addSubview(kmLabel)
        backView.addSubview(dateLabel)
        
        petImageView.anchor(top: contentView.topAnchor,
                            centerX: backView.centerXAnchor,
                            width: 40,
                            height: 40,
                            padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        
        backView.anchor(top: petImageView.centerYAnchor,
                            leading: contentView.leadingAnchor,
                            bottom: contentView.bottomAnchor,
                            trailing: contentView.trailingAnchor,
                            padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
        
        dateLabel.anchor(leading: backView.leadingAnchor,
                         bottom: backView.bottomAnchor,
                         trailing: backView.trailingAnchor,
                         padding: UIEdgeInsets(top: 0, left: 5, bottom: 5, right: 5))

        distanceLabel.anchor(leading: backView.leadingAnchor,
                          trailing: backView.trailingAnchor,
                          centerY: backView.centerYAnchor,
                          padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        
        kmLabel.anchor(top: distanceLabel.bottomAnchor,
                       leading: backView.leadingAnchor,
                       trailing: backView.trailingAnchor,
                       padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        
        contentView.layoutIfNeeded()
        petImageView.makeRound()
    }
    
    func configureCell(pet: Pet, trackInfo: TrackInfo) {
        
        let imageUrl = URL(string: pet.petImage)
        
        petImageView.kf.setImage(with: imageUrl)
        
        distanceLabel.text = "\(String(format: "%.2f", trackInfo.distanceMeter / 1000))"
        
        dateLabel.text = trackInfo.startTime.dateValue().displayTimeInNormalStyle()
    }
}
