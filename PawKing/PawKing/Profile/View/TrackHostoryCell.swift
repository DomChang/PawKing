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
    
    let distanceLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(pet: Pet, trackInfo: TrackInfo) {
        
        contentView.backgroundColor = .Blue2
        
        let vStack = UIStackView(arrangedSubviews: [dateLabel, distanceLabel, petNameLabel])
        
        vStack.axis = .vertical
        vStack.distribution = .fillEqually
        
        contentView.addSubview(vStack)
        
        vStack.anchor(top: contentView.topAnchor,
                      leading: contentView.leadingAnchor,
                      bottom: contentView.bottomAnchor,
                      trailing: contentView.trailingAnchor,
                      padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        
        contentView.layer.cornerRadius = 5

        dateLabel.textColor = .DarkBlue
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        dateLabel.textAlignment = .center
        
        distanceLabel.textColor = .DarkBlue
        distanceLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        distanceLabel.textAlignment = .center

        petNameLabel.textColor = .white
        petNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        petNameLabel.textAlignment = .center
        petNameLabel.backgroundColor = .Blue1
        petNameLabel.layer.cornerRadius = 5
        petNameLabel.layer.masksToBounds = true
        
        petNameLabel.text = pet.name
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy / MM / dd"
        
        let trackDate = dateFormatter.string(from: trackInfo.startTime.dateValue())
        
        dateLabel.text = trackDate
        
        let distance = computeDistance(from: trackInfo.track.map { $0.transferToCoordinate2D() })
        
        distanceLabel.text = "\(String(format: "%.2f", distance / 1000)) km"
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
