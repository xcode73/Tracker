//
//  Date+Truncated.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 10.10.2024.
//

import Foundation

extension Date {
    var truncated: Date? {
        get {
            let calendar = Calendar.current
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
            dateComponents.timeZone = NSTimeZone.system
            return calendar.date(from: dateComponents)
        }
    }
}
