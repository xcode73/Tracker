//
//  CategoryUI.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.11.2024.
//

import Foundation

struct CategoryUI: Equatable {
    let id: UUID
    let title: String
    let trackers: [TrackerUI]

    init(categoryID: UUID, title: String, trackers: [TrackerUI] = []) {
        self.id = categoryID
        self.title = title
        self.trackers = trackers
    }

    init(from entity: CategoryCoraData) {
        self.id = entity.categoryId
        self.title = entity.title

        if let trackersSet = entity.trackers as? Set<TrackerCoreData> {
            self.trackers = trackersSet.map { TrackerUI(from: $0) }
        } else {
            self.trackers = []
        }
    }
}
