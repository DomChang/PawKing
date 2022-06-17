//
//  UIColor+Extension.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/15.
//

import UIKit

private enum PKColor: String {

    // swiftlint:disable identifier_name
    case O1
    
    case G1
}

extension UIColor {

    static let O1 = PKColor(.O1)
    
    static let G1 = PKColor(.G1)

    
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
