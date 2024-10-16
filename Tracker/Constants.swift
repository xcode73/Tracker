//
//  Constants.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 29.09.2024.
//

import UIKit

enum Constants {
    static let weekDays: [WeekDay] = WeekDay.allCases
    
    static let emojis: [String] = [
        "🙂", "😻", "🌺", "🐶","❤️", "😱", "😇", "😡","🥶",
        "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]

    static let selectionColors: [String] = [
        "YPSelection1", "YPSelection2", "YPSelection3",
        "YPSelection4", "YPSelection5", "YPSelection6",
        "YPSelection7", "YPSelection8", "YPSelection9",
        "YPSelection10", "YPSelection11", "YPSelection12",
        "YPSelection13", "YPSelection14", "YPSelection15",
        "YPSelection16", "YPSelection17", "YPSelection18"
    ]
    
    enum Fonts {
        static let ypBold34: UIFont = UIFont.systemFont(ofSize: 34, weight: .bold)
        static let ypBold32: UIFont = UIFont.systemFont(ofSize: 32, weight: .bold)
        static let ypBold19: UIFont = UIFont.systemFont(ofSize: 19, weight: .bold)
        static let ypRegular17: UIFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        static let ypMedium16: UIFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let ypMedium12: UIFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        static let ypMedium10: UIFont = UIFont.systemFont(ofSize: 10, weight: .medium)
    }
}
