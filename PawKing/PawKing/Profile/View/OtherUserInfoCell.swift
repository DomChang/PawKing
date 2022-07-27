//
//  OtherUserInfoCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/24.
//

import UIKit

enum UserConnectStatus: String {
    
    case connect = "Connect"
    
    case disconnect = "Disconnect"
    
    case requested = "Requested"
}

class OtherUserInfoCell: UserInfoCell {
    
    static let identifier = "\(OtherUserInfoCell.self)"
    
    func configureCell(user: User, postCount: Int, connectStatus: UserConnectStatus) {
        super.configureCell(user: user, postCount: postCount)
        
        leftButton.setTitle(connectStatus.rawValue, for: .normal)
        leftButton.setTitleColor(.white, for: .normal)

        setConnectButton(connectStatus: connectStatus)
        
        rightButton.setTitle("Send Message", for: .normal)
    }
    
    private func setConnectButton(connectStatus: UserConnectStatus) {
        
        switch connectStatus {
            
        case .connect:
            
            leftButton.backgroundColor = .CoralOrange
            
            leftButton.layer.borderWidth = 0
            
        case .requested, .disconnect:
            
            leftButton.backgroundColor = .BattleGrey
            
            leftButton.layer.borderWidth = 1
        }
    }
}
