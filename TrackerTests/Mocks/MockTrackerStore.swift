//
//  MockTrackerStore.swift
//  TrackerTests
//
//  Created by Nikolai Eremenko on 07.02.2025.
//

import CoreData
@testable import Tracker

final class MockTrackerStore: TrackerStore {
    private var mockDate: Date {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: 2025, month: 1, day: 1)
        return calendar.date(from: dateComponents)?.truncated ?? Date()
    }

    init(dataStore: DataStoreProtocol) throws {
        try super.init(dataStore: dataStore)
        try populateMockData(Mocks.trackers)
    }

    func populateMockData(_ mockTrackers: [MockTracker]) throws {
        let fooCategory = CategoryCoraData(context: context)
        fooCategory.categoryId = UUID()
        fooCategory.title = "Foo"

        let bazCategory = CategoryCoraData(context: context)
        bazCategory.categoryId = UUID()
        bazCategory.title = "Baz"

        try dataStore.saveContext()

        var schedule: [WeekDay]?
        var date: Date?

        for mockTracker in mockTrackers {
            if mockTracker.hasSchedule {
                schedule = WeekDay.ordered()
            } else {
                date = mockDate
            }

            let trackerUI = TrackerUI(
                id: UUID(),
                title: mockTracker.name,
                color: mockTracker.color,
                emoji: mockTracker.emoji,
                isPinned: mockTracker.isPinned,
                schedule: schedule,
                date: date
            )

            let tracker = TrackerCoreData(context: context)
            let category = (mockTracker.categoryName == "Foo") ? fooCategory : bazCategory

            tracker.update(from: trackerUI, category: category, in: context)
        }

        try dataStore.saveContext()
    }
}
