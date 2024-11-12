//
//  TrackerModel.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 25.09.2024.
//

import Foundation

struct TrackerCategory: Codable {
    let title: String
    let trackers: [Tracker]
}

struct Tracker: Codable, Identifiable {
    let id: UUID
    let title: String
    let color: String
    let emoji: String
    let schedule: Schedule
}

struct Schedule: Codable {
    let type: ScheduleType
}

enum ScheduleType: Codable {
    case regular([WeekDay])
    case special(Date)
}

struct TrackerRecord: Codable {
    let trackerId: UUID
    let date: Date
}
