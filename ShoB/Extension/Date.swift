//
//  Date.swift
//  ShoB
//
//  Created by Dara Beng on 7/19/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


extension Date {
    
    /// Current date object with components year, month, day, hour, and minute.
    static var currentYMDHM: Date {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        return calendar.date(from: components) ?? Date()
    }
}
