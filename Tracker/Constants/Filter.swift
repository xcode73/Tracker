//
//  Filter.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 26.01.2025.
//

import Foundation

enum Filter: String, CaseIterable {
    case all
    case today
    case completed
    case notCompleted

    var title: String {
        switch self {
        case .all:
            return NSLocalizedString("filterTrackerAll", comment: "")
        case .today:
            return NSLocalizedString("filterTrackerToday", comment: "")
        case .completed:
            return NSLocalizedString("filterTrackerCompleted", comment: "")
        case .notCompleted:
            return NSLocalizedString("filterTrackerNotCompleted", comment: "")
        }
    }
}
