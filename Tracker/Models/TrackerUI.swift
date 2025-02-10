//
//  TrackerUI.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.11.2024.
//

import Foundation

struct TrackerUI: Identifiable, Equatable {
    let id: UUID
    let title: String
    let color: String
    let emoji: String
    let isPinned: Bool
    let schedule: [WeekDay]?
    let date: Date?

    init(
        id: UUID,
        title: String,
        color: String,
        emoji: String,
        isPinned: Bool,
        schedule: [WeekDay]?,
        date: Date?
    ) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.isPinned = isPinned
        self.schedule = schedule
        self.date = date
    }

    init(
        with schedule: [WeekDay],
        id: UUID,
        title: String,
        color: String,
        emoji: String,
        isPinned: Bool
    ) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.isPinned = isPinned
        self.schedule = schedule
        self.date = nil
    }

    init(
        with date: Date,
        id: UUID,
        title: String,
        color: String,
        emoji: String,
        isPinned: Bool
    ) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.isPinned = isPinned
        self.schedule = nil
        self.date = date
    }

    init(from entity: TrackerCoreData) {
        self.id = entity.trackerId
        self.title = entity.title
        self.color = entity.color
        self.emoji = entity.emoji
        self.isPinned = entity.isPinned
        self.date = entity.date

        if let scheduleSet = entity.schedule as? Set<ScheduleCoreData> {
            self.schedule = scheduleSet.map { $0.weekDay }
        } else {
            self.schedule = nil
        }
    }
}
