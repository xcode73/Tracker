//
//  WeekDay.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 03.10.2024.
//

import Foundation

@objc
public enum WeekDay: Int16, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    // MARK: - Init
    init(date: Date = Date()) {
        let cal = Calendar.current
        let weekDay = cal.component(.weekday, from: date)
        guard let day = WeekDay(rawValue: Int16(weekDay)) else {
            fatalError("Unsupported Weekday")
        }

        self = day
    }
}

// MARK: - CustomStringConvertible
extension WeekDay: CustomStringConvertible {
    var dateFromWeekDay: Date {
        let cal = Calendar.current
        guard let date = cal.date(from: DateComponents(weekday: Int(self.rawValue))) else {
            return Date()
        }

        return date
    }

    var localizedName: String {
        let cal = Calendar.current
        guard cal.standaloneWeekdaySymbols.count == WeekDay.allCases.count else {
            return "Unsupported calendar"
        }

        return cal.standaloneWeekdaySymbols[Int(self.rawValue) - 1].capitalized
    }

    var localizedShortName: String {
        let cal = Calendar.current
        guard cal.shortStandaloneWeekdaySymbols.count == WeekDay.allCases.count else {
            return "Unsupported calendar"
        }

        return cal.shortStandaloneWeekdaySymbols[Int(self.rawValue) - 1].capitalized
    }

    public var description: String {
        return localizedName
    }
}

extension WeekDay {
    static func ordered(calendar: Calendar = .current) -> WeekDay.AllCases {
        guard let firstDay = WeekDay(rawValue: Int16(calendar.firstWeekday)) else {
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
