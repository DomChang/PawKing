//
//  TrackDashboardView.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/28.
//

import UIKit

class TrackDashboardView: UIView {
    
    private let timeIcon = UIImageView()
    
    let timeLabel = UILabel()
    
    private let distanceIcon = UIImageView()
    
    let distanceLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func style() {
        
        backgroundColor = .BattleGrey
        
        timeIcon.image = UIImage.asset(.Icons_24px_Clock)
        
        timeLabel.textColor = .white
        timeLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        timeLabel.textAlignment = .center
        timeLabel.text = "00:00:00"

        distanceIcon.image = UIImage.asset(.Icons_24px_Distance)
        
        distanceLabel.textColor = .white
        distanceLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        distanceLabel.textAlignment = .center
        distanceLabel.text = "0.00 km"
    }
    
    private func layout() {
        
        let timeHStack = UIStackView(arrangedSubviews: [timeIcon, timeLabel])
        timeHStack.axis = .horizontal
        timeHStack.distribution = .fillProportionally
        timeHStack.spacing = 5
        
        timeIcon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let distanceHStack = UIStackView(arrangedSubviews: [distanceIcon, distanceLabel])
        distanceHStack.axis = .horizontal
        distanceHStack.distribution = .fillProportionally
        distanceHStack.spacing = 5
        
        timeIcon.constrainWidth(constant: 20)
        timeIcon.constrainHeight(constant: 20)
        
        distanceIcon.constrainWidth(constant: 20)
        distanceIcon.constrainHeight(constant: 20)
        
        distanceIcon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        addSubview(timeHStack)
        addSubview(distanceHStack)
        
        timeHStack.anchor(leading: leadingAnchor,
                          bottom: centerYAnchor,
                          trailing: trailingAnchor,
                            padding: UIEdgeInsets(top: 0, left: 16, bottom: 5, right: 16))
        
        distanceHStack.anchor(top: centerYAnchor,
                              leading: timeHStack.leadingAnchor,
                              trailing: timeHStack.trailingAnchor,
                            padding: UIEdgeInsets(top: 5, left: 0, bottom: 10, right: 0))
        
        layoutIfNeeded()
        setRadiusWithShadow(20)
    }
}
