//
//  HeaderCollectionReusableView.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/23.
//

import UIKit

protocol ModeChangeHeaderDelegate {
    
    func didTapAll()
    
    func didTapFriend()
}

class ModeChangeHeaderReusableView: UICollectionReusableView {
    
    static let identifier = "ModeChangeHeaderReusableView"
    
    var delegate: ModeChangeHeaderDelegate?
    
    let allModeButton = UIButton()
    
    let friendModeButton = UIButton()
    
    private let bottomLine = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        allModeButton.addTarget(self, action: #selector(didTapAll), for: .touchUpInside)
        friendModeButton.addTarget(self, action: #selector(didTapFriend), for: .touchUpInside)
    }
    
    private func style() {
        
        backgroundColor = .white
        
        allModeButton.setTitle("All", for: .normal)
        friendModeButton.setTitle("Friends", for: .normal)
        
        allModeButton.setTitleColor(.O1, for: .normal)
        friendModeButton.setTitleColor(.O1, for: .normal)
        
        bottomLine.backgroundColor = .O1
    }
    
    private func layout() {
        
        let hStackView = UIStackView(arrangedSubviews: [allModeButton, friendModeButton])
        hStackView.distribution = .fillEqually

        addSubview(hStackView)
        addSubview(bottomLine)

        hStackView.anchor(top: topAnchor,
                          leading: leadingAnchor,
                          trailing: trailingAnchor,
                          height: 50)
        
        bottomLine.anchor(leading: leadingAnchor,
                          bottom: bottomAnchor,
                          width: frame.width / 2,
                          height: 1)
    }
    
    @objc func didTapAll() {
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.bottomLine.center.x = self.frame.width * 1 / 4
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.delegate?.didTapAll()
        }
    }
    
    @objc func didTapFriend() {
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.bottomLine.center.x = self.frame.width * 3 / 4
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.delegate?.didTapFriend()
        }
    }
}
