//
//  WeekDay.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 03.10.2024.
//

import Foundation

enum WeekDay: Int, CaseIterable, Codable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    // MARK: - Public Type Properties
    
    static var today: WeekDay {
        return WeekDay()
    }
    
    // MARK: - Setup
    
    init(date: Date = Date()) {
        let cal = Calendar.current
        let weekDay = cal.component(.weekday, from: date)
        guard let day = WeekDay(rawValue: weekDay) else {
            fatalError("Unsupported Weekday")
        }
        self = day
    }
}

// MARK: - CustomStringConvertible
extension WeekDay: CustomStringConvertible {
    var dateFromWeekDay: Date {
        let cal = Calendar.current
        return cal.date(from: DateComponents(weekday: self.rawValue))!
    }
    var localizedName: String {
        let cal = Calendar.current
        guard cal.standaloneWeekdaySymbols.count == WeekDay.allCases.count else {
            return "Unsupported calendar"
        }
        return cal.standaloneWeekdaySymbols[self.rawValue - 1].capitalized
    }
    var localizedShortName: String {
        let cal = Calendar.current
        guard cal.shortStandaloneWeekdaySymbols.count == WeekDay.allCases.count else {
            return "Unsupported calendar"
        }
        return cal.shortStandaloneWeekdaySymbols[self.rawValue - 1].capitalized
    }
    var description: String {
        return localizedName
    }
}

extension WeekDay {
    /// Ordered list of all days according to a given calendar
    static func ordered(calendar: Calendar = .current) -> WeekDay.AllCases {
        guard let firstDay = WeekDay(rawValue: calendar.firstWeekday) else {
            return allCases
        }
        let all = WeekDay.allCases
        let firstIdx = all.firstIndex(of: firstDay) ?? all.startIndex
        return Array(all[firstIdx..<all.endIndex] + all[all.startIndex..<firstIdx])
    }
    
    var next: WeekDay! {
        let all = WeekDay.allCases
        return all.firstIndex(of: self)
            .map(all.index(after:))
            .flatMap { all.indices.contains($0) ? all[$0] : all.first }
    }
}
