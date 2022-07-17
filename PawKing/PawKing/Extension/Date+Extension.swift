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
    
    func displayTimeInChatStyle() -> String {
        
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let dateFormatter = DateFormatter()
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let year = 48 * week
        
        if secondsAgo < day {
            
            dateFormatter.dateFormat = "HH:mm"
            
        } else if secondsAgo / day < year {
            
            dateFormatter.dateFormat = "MMM dd・HH:mm"
            
        } else {
            
            dateFormatter.dateFormat = "MMM dd, yyyy・HH:mm"
        }
        return dateFormatter.string(from: self)
    }
    
    func displayTimeInCounterStyle(since startTime: Date) -> String {
        
        let delta = startTime.distance(to: self)
        
        let dateFormatter = DateComponentsFormatter()
        
        dateFormatter.allowedUnits = [.hour, .minute, .second]
        
        dateFormatter.zeroFormattingBehavior = .pad

        return dateFormatter.string(from: delta) ?? ""
    }
    
    func displayTimeInNormalStyle() -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        return dateFormatter.string(from: self)
    }
    
    func displayTimeInHourMinuteStyle() -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: self)
    }
    
    func displayTimeInAgeStyle() -> String {
        
        let delta = self.distance(to: Date())
        
        let dateFormatter = DateComponentsFormatter()
        
        dateFormatter.allowedUnits = [.year, .month]
        
        dateFormatter.zeroFormattingBehavior = .dropLeading
        dateFormatter.unitsStyle = .short
        
        return dateFormatter.string(from: delta) ?? ""
    }
}
