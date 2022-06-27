//
//  ContentButtonCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/19.
//

import UIKit

protocol ContentButtonCellDelegate {
    
    func didTapPhoto()
    
    func didTapTrack()
}

class ContentButtonCell: UICollectionViewCell {
    
    static let identifier = "\(ContentButtonCell.self)"
    
    var delegate: ContentButtonCellDelegate?
    
    let photoContentButton = UIButton()
    
    let trackContentButton = UIButton()
    
    let bottomView = UIView()
    
    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        photoContentButton.addTarget(self, action: #selector(didTapPhotoButton), for: .touchUpInside)
        trackContentButton.addTarget(self, action: #selector(didTapTrackButton), for: .touchUpInside)
        
        style()
        layout()
        didTapPhotoButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func style() {
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        photoContentButton.setTitle("Photo", for: .normal)
        photoContentButton.setTitleColor(.Gray1, for: .normal)
        photoContentButton.setTitleColor(.Orange1, for: .selected)
        photoContentButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        trackContentButton.setTitle("Track", for: .normal)
        trackContentButton.setTitleColor(.Gray1, for: .normal)
        trackContentButton.setTitleColor(.Orange1, for: .selected)
        trackContentButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        bottomView.backgroundColor = .Orange2
    }
    
    private func layout() {
        
        contentView.addSubview(bottomView)
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(photoContentButton)
        stackView.addArrangedSubview(trackContentButton)
        
        stackView.fillSuperview()
        
        bottomView.anchor(centerY: photoContentButton.centerYAnchor,
                          centerX: photoContentButton.centerXAnchor,
                          width: 150,
                          height: 40)
        
        bottomView.layer.cornerRadius = 5
    }
    
    @objc func didTapPhotoButton() {
        
        photoContentButton.isSelected = true
        trackContentButton.isSelected = false
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.bottomView.center.x = self.photoContentButton.center.x
        })
        
        self.delegate?.didTapPhoto()
    }
    
    @objc func didTapTrackButton() {
        
        photoContentButton.isSelected = false
        trackContentButton.isSelected = true
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.bottomView.center.x = self.trackContentButton.center.x
        })
        
        self.delegate?.didTapTrack()
    }
}
