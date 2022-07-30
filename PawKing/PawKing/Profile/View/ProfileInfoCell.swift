//
//  ProfileInfoCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/24.
//

import UIKit

class ProfileInfoCell: UserInfoCell {
    
    static let identifier = "\(ProfileInfoCell.self)"
    
    private let photoHelper = PKPhotoHelper()
    
    private let user = UserManager.shared.currentUser
    
    override func setup() {
        super.setup()
        
        photoHelper.completionHandler = { [weak self] image in
            
            guard let self = self,
                  let user = self.user else { return }
            
            self.userImageView.image = image
            
            UserManager.shared.uploadUserPhoto(userId: user.id,
                                        image: image) { result in
                switch result {

                case .success:
                    
                    print("update user photo success.")
                    
                case .failure(let error):
                    
                    LottieWrapper.shared.showError(error: error)
                }
            }
        }
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                  action: #selector(didTapUserImage)))
        userImageView.isUserInteractionEnabled = true
        
        leftButton.setTitle("Edit Profile", for: .normal)
        
        rightButton.setTitle("Add Pet", for: .normal)
    }
    
    @objc func didTapUserImage() {
        
        guard let topMostViewController = topMostController() else { return }
        
        photoHelper.presentActionSheet(from: topMostViewController)
    }
    
}
