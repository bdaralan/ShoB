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
    
    /// Get the start of today using the current calendar.
    /// - Parameter addingDay: The number of day to add. The default is 0.
    static func startOfToday(addingDay: Int = 0) -> Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return addingDay == 0 ? today : calendar.date(byAdding: .day, value: addingDay, to: today)!
    }
}


extension DateFormatter {
    
    static let shortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}
