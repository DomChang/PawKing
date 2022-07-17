//
//  UITabBar+Extension.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/16.
//

import Foundation
import UIKit.UITabBar

private let tabBarItemTag: Int = 10090

extension UITabBar {
    
    public func addItemBadge(atIndex index: Int) {
        guard let itemCount = self.items?.count, itemCount > 0 else {
            return
        }
        guard index < itemCount else {
            return
        }
        removeItemBadge(atIndex: index)
        
        let badgeView = UIView()
        badgeView.tag = tabBarItemTag + Int(index)
        badgeView.layer.cornerRadius = 8
        badgeView.backgroundColor = UIColor.Orange1
        badgeView.layer.borderColor = UIColor.white.cgColor
        badgeView.layer.borderWidth = 4
        badgeView.layer.masksToBounds = true
        
        let tabFrame = self.frame
        let percentX = (CGFloat(index) + 0.5) / CGFloat(itemCount)
        let positionX = (percentX * tabFrame.size.width).rounded(.up)
        let positionY = (CGFloat(0.1) * tabFrame.size.height).rounded(.up)
        badgeView.frame = CGRect(x: positionX, y: positionY, width: 16, height: 16)
        addSubview(badgeView)
    }
    
    public func removeItemBadge(atIndex index: Int) {
        
        for subView in self.subviews {
            
            if subView.tag == (tabBarItemTag + index) {
                
                subView.removeFromSuperview()
            }
        }
    }
}
