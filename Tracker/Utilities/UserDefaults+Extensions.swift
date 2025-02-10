//
//  UserDefaults+Extensions.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 30.01.2025.
//

import Foundation

extension UserDefaults {
    private enum Keys {
        static let selectedFilter = "selectedFilter"
        static let isOnboardingCompleted = "isOnboardingCompleted"
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

    var isOnboardingCompleted: Bool {
        get {
            bool(forKey: Keys.isOnboardingCompleted)
        }
        set {
            setValue(newValue, forKey: Keys.isOnboardingCompleted)
        }
    }
}
