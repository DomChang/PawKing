//
//  Date+Extension.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/28.
//

import Foundation

extension Date {
    
    func displayTimeInSocialMediaStyle() -> String {
        
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        
        if secondsAgo < minute {
            
            return "\(secondsAgo) second ago"
            
        } else if secondsAgo < hour {
            
            return "\(secondsAgo / minute) minutes ago"
            
        } else if secondsAgo < day {
            
            return "\(secondsAgo / hour) hours ago"
            
        } else if secondsAgo / day == 1 {
            
            return "\(secondsAgo / day) day ago"
            
        } else if secondsAgo < week {
            
            return "\(secondsAgo / day) days ago"
            
        } else if secondsAgo < week * 5 {
            
            return "\(secondsAgo / week) weeks ago"
            
        } else {
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "MMMM dd, yyyy・HH:mm"
            
            return dateFormatter.string(from: self)
        }
    }
}
