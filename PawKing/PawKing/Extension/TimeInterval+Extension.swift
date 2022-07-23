//
//  TimeInterval+Extension.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/19.
//

import Foundation

extension TimeInterval {
    
    func timeString() -> String {
        
        let hours = Int(self) / 3600
        
        let minutes = Int(self) / 60 % 60
        
        let seconds = Int(self) % 60
        
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}
