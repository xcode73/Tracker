//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 25.09.2024.
//

import Foundation

/// сущность для хранения записи о том, что некий трекер был выполнен на некоторую дату;
/// хранит id трекера, который был выполнен и дату.
struct TrackerRecord: Hashable {
    let trackerId: UUID
    let date: Date
    let isCompleted: Bool
}
