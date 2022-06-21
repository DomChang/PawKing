//
//  UIImage+Extension.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/14.
//

import UIKit.UIImage

enum ImageAsset: String {

    // Map tab - Tab
    
    // swiftlint:disable identifier_name
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
    
    case Icons_36px_RecordTrack_Normal
    case Icons_36px_RecordTrack_Selected
    
    case Image_Placeholder
}
// swiftlint:enable identifier_name

extension UIImage {

    static func asset(_ asset: ImageAsset) -> UIImage? {

        return UIImage(named: asset.rawValue)
    }
    
    func resized(to newSize: CGSize) -> UIImage {
            return UIGraphicsImageRenderer(size: newSize).image { _ in
                let hScale = newSize.height / size.height
                let vScale = newSize.width / size.width
                let scale = max(hScale, vScale) // scaleToFill
                let resizeSize = CGSize(width: size.width*scale, height: size.height*scale)
                var middle = CGPoint.zero
                if resizeSize.width > newSize.width {
                    middle.x -= (resizeSize.width-newSize.width)/2.0
                }
                if resizeSize.height > newSize.height {
                    middle.y -= (resizeSize.height-newSize.height)/2.0
                }
                
                draw(in: CGRect(origin: middle, size: resizeSize))
            }
        }
}