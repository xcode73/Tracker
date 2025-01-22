//
//  Date+Truncated.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 10.10.2024.
//

import Foundation

extension Date {
    var truncated: Date? {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        dateComponents.timeZone = calendar.timeZone
        return calendar.date(from: dateComponents)
    }
}
