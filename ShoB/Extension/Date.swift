//
//  Date.swift
//  ShoB
//
//  Created by Dara Beng on 7/19/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


extension Date {
    
    static func current(_ calendarComponents: Set<Calendar.Component>) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents(calendarComponents, from: Date())
        return calendar.date(from: components) ?? Date()
    }
    
    /// Current date including year, month, day, hour, and minute.
    static var currentYMDHM: Date {
        current([.year, .month, .day, .hour, .minute])
    }
    
    /// Current date with including year, month, and day.
    static var currentYMD: Date {
        current([.year, .month, .day])
    }
    
    func removeHourMinute() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components) ?? self
    }
}


extension DateFormatter {
    
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
