//
//  TrackerModel.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 25.09.2024.
//

import Foundation

struct TrackerCategory: Codable {
    let title: String
    let trackers: [Tracker]?
}

struct Tracker: Codable, Identifiable {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: [WeekDay]?
    let daysCompleted: Int?
}

/// сущность для хранения записи о том, что некий трекер был выполнен на некоторую дату;
/// хранит id трекера, который был выполнен и дату.
struct TrackerRecord: Codable, Hashable, Identifiable {
    let id: UUID
    let date: Date
}
