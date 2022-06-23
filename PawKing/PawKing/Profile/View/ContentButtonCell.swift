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
    
    let bottomLine = UIView()
    
    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        photoContentButton.addTarget(self, action: #selector(didTapPhotoButton), for: .touchUpInside)
        trackContentButton.addTarget(self, action: #selector(didTapTrackButton), for: .touchUpInside)
        
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func style() {
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        photoContentButton.setTitle("照片", for: .normal)
        photoContentButton.setTitleColor(.O1, for: .normal)
        
        trackContentButton.setTitle("軌跡", for: .normal)
        trackContentButton.setTitleColor(.O1, for: .normal)
        
        bottomLine.backgroundColor = .O1
    }
    
    private func layout() {
        
        contentView.addSubview(stackView)
        contentView.addSubview(bottomLine)
        
        stackView.fillSuperview()
        
        bottomLine.anchor(leading: contentView.leadingAnchor,
                          bottom: contentView.bottomAnchor,
                          width: contentView.frame.width / 2,
                          height: 1)
        
        stackView.addArrangedSubview(photoContentButton)
        stackView.addArrangedSubview(trackContentButton)
    }
    
    @objc func didTapPhotoButton() {
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.bottomLine.center.x = self.contentView.frame.width * 1 / 4
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.delegate?.didTapPhoto()
        }
    }
    
    @objc func didTapTrackButton() {
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.bottomLine.center.x = self.contentView.frame.width * 3 / 4
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.delegate?.didTapTrack()
        }
    }
}
