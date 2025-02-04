//
//  Constants.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 29.09.2024.
//  Description: This file holds all constant values used throughout the app, such as API endpoints, color schemes,
//               and default settings.
//

import UIKit

enum Constants {
    static let weekDays: [WeekDay] = WeekDay.ordered()

    static let emojis: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]

    static let selectionColors: [String] = [
        "YPSelection1", "YPSelection2", "YPSelection3",
        "YPSelection4", "YPSelection5", "YPSelection6",
        "YPSelection7", "YPSelection8", "YPSelection9",
        "YPSelection10", "YPSelection11", "YPSelection12",
        "YPSelection13", "YPSelection14", "YPSelection15",
        "YPSelection16", "YPSelection17", "YPSelection18"
    ]

    static func appDelegate() -> AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("could not get app delegate ")
        }

        return delegate
     }

    static let trackersCollectionViewGeometricParam = GeometricParams(
        cellCount: 2,
        topInset: 8,
        bottomInset: 16,
        leftInset: 16,
        rightInset: 16,
        cellSpacing: 9,
        cellHeight: 132,
        lineSpacing: 16,
        headerHeight: 18
    )
}
