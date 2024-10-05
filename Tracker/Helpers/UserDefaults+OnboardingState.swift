//
//  UserDefaults+OnboardingState.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 30.09.2024.
//

import Foundation

extension UserDefaults {
    private enum UserDefaultsKeys: String {
        case isOnboardingCompleted
    }
    
    var isOnboardingCompleted: Bool {
        get {
            bool(forKey: UserDefaultsKeys.isOnboardingCompleted.rawValue)
        }
        
        set {
            setValue(newValue, forKey: UserDefaultsKeys.isOnboardingCompleted.rawValue)
        }
    }
}
