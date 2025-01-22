//
//  NewTracker.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 08.12.2024.
//

import Foundation

struct NewTracker {
    var id: UUID?
    var categoryTitle: String?
    var title: String?
    var emoji: String?
    var color: String?
    var schedule: [WeekDay]?
    var date: Date?

    init(from tracker: Tracker) {
        id = tracker.id
        categoryTitle = tracker.categoryTitle
        title = tracker.title
        emoji = tracker.emoji
        color = tracker.color
        schedule = tracker.schedule
        date = tracker.date
    }

    init(id: UUID? = nil,
         categoryTitle: String? = nil,
         title: String? = nil,
         emoji: String? = nil,
         color: String? = nil,
         schedule: [WeekDay]? = nil,
         date: Date? = nil) {
        self.id = id
        self.categoryTitle = categoryTitle
        self.title = title
        self.emoji = emoji
        self.color = color
        self.schedule = schedule
        self.date = date
    }
}
