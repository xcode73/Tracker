//
//  UserDefaults+Filter.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 30.01.2025.
//

import Foundation

extension UserDefaults {
    private enum Keys {
        static let selectedFilter = "selectedFilter"
    }

    func saveFilter(_ filter: Filter) {
        set(filter.rawValue, forKey: Keys.selectedFilter)
    }

    func loadFilter() -> Filter {
        guard let rawValue = string(forKey: Keys.selectedFilter),
              let filter = Filter(rawValue: rawValue) else {
            return .all
        }
        return filter
    }
}
