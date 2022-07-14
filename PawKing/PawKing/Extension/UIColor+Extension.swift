//
//  UIColor+Extension.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/15.
//

import UIKit

private enum PKColor: String {

    // swiftlint:disable identifier_name
    
    case Brown1
    
    case Blue1
    
    case Blue2
    
    case Blue3
    
    case BattleGrey
    
    case BattleGreyLight
    
    case Green1
    
    case YB1
    
    case Orange1
    
    case Orange2
    
    case Yello1
    
    case Gray1
    
    case LightBlack
    
    case LightGray
}

extension UIColor {
    
    static let Brown1 = PKColor(.Brown1)
    
    static let Blue1 = PKColor(.Blue1)
    
    static let Blue2 = PKColor(.Blue2)
    
    static let Blue3 = PKColor(.Blue3)
    
    static let BattleGrey = PKColor(.BattleGrey)
    
    static let BattleGreyLight = PKColor(.BattleGreyLight)
    
    static let G1 = PKColor(.Green1)
    
    static let YB1 = PKColor(.YB1)

    static let Orange1 = PKColor(.Orange1)
    
    static let Orange2 = PKColor(.Orange2)
    
    static let Yello1 = PKColor(.Yello1)
    
    static let Gray1 = PKColor(.Gray1)
    
    static let LightBlack = PKColor(.LightBlack)
    
    static let LightGray = PKColor(.LightGray)

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
