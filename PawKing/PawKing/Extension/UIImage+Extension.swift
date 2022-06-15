//
//  UIImage+Extension.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/14.
//

import UIKit.UIImage

enum ImageAsset: String {

    // Map tab - Tab
    
    case Icons_24px_Map_Normal
    case Icons_24px_Map_Selected
    
    case Icons_24px_Explore_Normal
    case Icons_24px_Explore_Selected
    
    case Icons_24px_Publish
    
    case Icons_24px_Chat_Normal
    case Icons_24px_Chat_Selected
    
    case Icons_24px_Profile_Normal
    case Icons_24px_Profile_Selected
    
    case Icons_36px_UserLocate_Normal
    case Icons_36px_UserLocate_Selected
}

extension UIImage {

    static func asset(_ asset: ImageAsset) -> UIImage? {

        return UIImage(named: asset.rawValue)
    }
}
