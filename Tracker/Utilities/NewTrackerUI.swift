//
//  NewTrackerUI.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 08.12.2024.
//

import Foundation

struct NewTrackerUI {
    var id: UUID?
    var title: String?
    var emoji: String?
    var color: String?
    var isPinned: Bool
    var schedule: [WeekDay]?
    var date: Date?

    init(from tracker: TrackerUI) {
        id = tracker.id
        title = tracker.title
        emoji = tracker.emoji
        color = tracker.color
        isPinned = tracker.isPinned
        schedule = tracker.schedule
        date = tracker.date
    }

    init(id: UUID? = nil,
         categoryTitle: String? = nil,
         title: String? = nil,
         emoji: String? = nil,
         color: String? = nil,
         isPinned: Bool = false,
         schedule: [WeekDay]? = nil,
         date: Date? = nil) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.color = color
        self.isPinned = isPinned
        self.schedule = schedule
        self.date = date
    }
}
