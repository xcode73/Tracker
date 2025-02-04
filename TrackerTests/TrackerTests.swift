//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Nikolai Eremenko on 02.02.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    private func setDate() -> Date {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: 2025, month: 1, day: 1)

        return calendar.date(from: dateComponents)?.truncated ?? Date()
    }

    // MARK: - Tests
    func testTabBarController() {
        let tabBarController = TabBarController()
        guard
            let trackersNavController = tabBarController.selectedViewController as? UINavigationController
        else {
            XCTFail("Could not get navController.")
            return
        }

        guard let trackersVC = trackersNavController.topViewController as? TrackersViewController else {
            XCTFail("Could not get trackersViewController.")
            return
        }

        trackersVC.datePicker.date = setDate()
        try? trackersVC.trackerStore.deleteAllCategories()
        try? trackersVC.trackerStore.createMockCategories()
        try? trackersVC.trackerStore.createMockTrackers(Mocks.trackers, mockDate: setDate())

        assertSnapshot(of: tabBarController, as: .image(traits: .init(userInterfaceStyle: .light)))
        assertSnapshot(of: tabBarController, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
