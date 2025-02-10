//
//  NewCategory.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 30.01.2025.
//

import Foundation

struct NewCategoryUI {
    var categoryId: UUID?
    var title: String?
    var trackers: [TrackerUI]?

    init(from category: CategoryUI) {
        self.categoryId = category.id
        self.title = category.title
        self.trackers = category.trackers
    }

    init(categoryId: UUID? = nil, title: String? = nil, trackers: [TrackerUI]? = nil) {
        self.categoryId = categoryId
        self.title = title
        self.trackers = trackers
    }
}
