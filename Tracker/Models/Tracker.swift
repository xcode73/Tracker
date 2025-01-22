//
//  Tracker.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.11.2024.
//

import Foundation

struct Tracker: Identifiable, Equatable {
    let id: UUID
    let categoryTitle: String
    let title: String
    let color: String
    let emoji: String
    let schedule: [WeekDay]?
    let date: Date?

    init(
        id: UUID,
        categoryTitle: String,
        title: String,
        color: String,
        emoji: String,
        schedule: [WeekDay]?,
        date: Date?
    ) {
        self.id = id
        self.categoryTitle = categoryTitle
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.date = date
    }

    init(with schedule: [WeekDay], id: UUID, categoryTitle: String, title: String, color: String, emoji: String) {
        self.id = id
        self.categoryTitle = categoryTitle
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.date = nil
    }

    init(with date: Date, id: UUID, categoryTitle: String, title: String, color: String, emoji: String) {
        self.id = id
        self.categoryTitle = categoryTitle
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = nil
        self.date = date
    }
}
