//
//  CALayer+Extension.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/26.
//

import UIKit

extension CALayer {
    func addGradientBorder(colors:[UIColor], width:CGFloat = 1) {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame =  CGRect(origin: CGPoint.zero, size: self.bounds.size)
        
        gradientLayer.startPoint = CGPoint(x:0.0, y:0.0)
        
        gradientLayer.endPoint = CGPoint(x:1.0,y:1.0)
        
        gradientLayer.colors = colors.map({$0.cgColor})

        let shapeLayer = CAShapeLayer()
        
        shapeLayer.lineWidth = width
        
        shapeLayer.path = UIBezierPath(rect: self.bounds).cgPath
        
        shapeLayer.fillColor = nil
        
        shapeLayer.strokeColor = UIColor.red.cgColor
        
        gradientLayer.mask = shapeLayer

        self.addSublayer(gradientLayer)
    }
}
