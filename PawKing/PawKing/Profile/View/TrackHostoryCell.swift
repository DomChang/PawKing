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
    
    let petNameLabel = UILabel()
    
    let dateLabel = UILabel()
    
    let distanLabel = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(pet: Pet, trackInfo: TrackInfo) {
        
        contentView.backgroundColor = .Blue1
        
        let vStack = UIStackView(arrangedSubviews: [dateLabel, distanLabel, petNameLabel])
        
        vStack.axis = .vertical
        vStack.distribution = .fillEqually
        
        contentView.addSubview(vStack)
        
        vStack.anchor(top: contentView.topAnchor,
                      leading: contentView.leadingAnchor,
                      bottom: contentView.bottomAnchor,
                      trailing: contentView.trailingAnchor,
                      padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        
        contentView.layer.cornerRadius = 5

        dateLabel.textColor = .white
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        dateLabel.textAlignment = .center
        
        distanLabel.textColor = .white
        distanLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        distanLabel.textAlignment = .center

        petNameLabel.textColor = .Orange2
        petNameLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        petNameLabel.textAlignment = .center
        
        petNameLabel.text = pet.name
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy / MM / dd"
        
        let trackDate = dateFormatter.string(from: trackInfo.startTime.dateValue())
        
        dateLabel.text = trackDate
        
        let distance = computeDistance(from: trackInfo.track.map { $0.transferToCoordinate2D() })
        
        distanLabel.text = "\(String(format: "%.2f", distance / 1000)) km"
    }
    
    func computeDistance(from points: [CLLocationCoordinate2D]) -> Double {
        
        guard let first = points.first else { return 0.0 }
        
        var prevPoint = first
        
        return points.reduce(0.0) { (count, point) -> Double in
            
            let newCount = count + CLLocation(latitude: prevPoint.latitude, longitude: prevPoint.longitude).distance(
                
                from: CLLocation(latitude: point.latitude, longitude: point.longitude))
            
            prevPoint = point
            
            return newCount
        }
    }
}
