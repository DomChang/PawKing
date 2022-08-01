//
//  ContentButtonCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/19.
//

import UIKit

protocol ContentButtonCellDelegate: AnyObject {
    
    func didTapPhoto()
    
    func didTapTrack()
}

class ContentButtonCell: UICollectionViewCell {
    
    static let identifier = "\(ContentButtonCell.self)"
    
    weak var delegate: ContentButtonCellDelegate?
    
    let photoContentButton = UIButton()
    
    let trackContentButton = UIButton()
    
    let buttonView = UIView()
    
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
        photoContentButton.setTitleColor(.MainGray, for: .normal)
        photoContentButton.setTitleColor(.CoralOrange, for: .selected)
        photoContentButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        trackContentButton.setTitle("Track", for: .normal)
        trackContentButton.setTitleColor(.MainGray, for: .normal)
        trackContentButton.setTitleColor(.CoralOrange, for: .selected)
        trackContentButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        buttonView.backgroundColor = .CoralOrange
    }
    
    private func layout() {
        
        contentView.addSubview(buttonView)
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(photoContentButton)
        stackView.addArrangedSubview(trackContentButton)
        
        stackView.anchor(top: contentView.topAnchor,
                         leading: contentView.leadingAnchor,
                         trailing: contentView.trailingAnchor,
                         padding: UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0))
        
        buttonView.anchor(top: stackView.bottomAnchor,
                          centerX: photoContentButton.centerXAnchor,
                          width: 10,
                          height: 10,
                          padding: UIEdgeInsets(top: -2, left: 0, bottom: 0, right: 0))
        
        buttonView.layer.cornerRadius = 5
    }
    
    @objc func didTapPhotoButton() {
        
        photoContentButton.isSelected = true
        trackContentButton.isSelected = false
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.buttonView.center.x = self.photoContentButton.center.x
        })
        
        self.delegate?.didTapPhoto()
    }
    
    @objc func didTapTrackButton() {
        
        photoContentButton.isSelected = false
        trackContentButton.isSelected = true
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.buttonView.center.x = self.trackContentButton.center.x
        })
        
        self.delegate?.didTapTrack()
    }
}
