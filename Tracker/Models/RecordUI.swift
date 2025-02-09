//
//  RecordUI.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 25.09.2024.
//

import Foundation

struct RecordUI {
    let trackerId: UUID
    let date: Date

    init(trackerId: UUID, date: Date) {
        self.trackerId = trackerId
        self.date = date
    }

    init(from entity: RecordCoreData) {
        self.trackerId = entity.trackerId
        self.date = entity.date
    }
}
