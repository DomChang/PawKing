//
//  UIColor+Extension.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/15.
//

import UIKit

private enum PKColor: String {

    // swiftlint:disable identifier_name
    
    case G1
    
    case YB1
    
    case O1
    
    case O2
    
    case Y1
    
    case Gray
    
    case LightBlack
}

extension UIColor {
    
    static let G1 = PKColor(.G1)
    
    static let YB1 = PKColor(.YB1)

    static let O1 = PKColor(.O1)
    
    static let O2 = PKColor(.O2)
    
    static let Y1 = PKColor(.Y1)
    
    static let Gray = PKColor(.Gray)
    
    static let LightBlack = PKColor(.LightBlack)

    // swiftlint:enable identifier_name
    
    private static func PKColor(_ color: PKColor) -> UIColor? {

        return UIColor(named: color.rawValue)
    }

    static func hexStringToUIColor(hex: String) -> UIColor {

        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
