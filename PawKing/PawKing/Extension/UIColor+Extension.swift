//
//  UIColor+Extension.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/15.
//

import UIKit

private enum PKColor: String {

    // swiftlint:disable identifier_name
    
    case Blue1
    
    case Blue2
    
    case BattleGrey
    
    case BattleGreyLight
    
    case BattleGreyUL
    
    case BattleGreyDark

    case Orange1
    
    case Gray1
    
    case LightBlack
    
    case LightGray
}

extension UIColor {

    static let Blue1 = PKColor(.Blue1)
    
    static let Blue2 = PKColor(.Blue2)
    
    static let BattleGrey = PKColor(.BattleGrey)
    
    static let BattleGreyLight = PKColor(.BattleGreyLight)
    
    static let BattleGreyUL = PKColor(.BattleGreyUL)
    
    static let BattleGreyDark = PKColor(.BattleGreyDark)
    
    static let LightBlack = PKColor(.LightBlack)

    static let Orange1 = PKColor(.Orange1)
    
    static let Gray1 = PKColor(.Gray1)
    
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
