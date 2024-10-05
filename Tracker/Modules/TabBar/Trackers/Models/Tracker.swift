//
//  Tracker.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 25.09.2024.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]?
    let date: Date?
}

