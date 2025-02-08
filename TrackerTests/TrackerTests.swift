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
    var dataStore: DataStoreProtocol!
    var analyticsService: AnalyticsServiceProtocol!

    override func setUpWithError() throws {
        try super.setUpWithError()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Error: could not get app delegate ")
        }

        dataStore = appDelegate.dataStore
        analyticsService = appDelegate.analyticsService
    }

    override func tearDownWithError() throws {
        dataStore = nil
        analyticsService = nil
        try super.tearDownWithError()
    }

    private func setDate() -> Date {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: 2025, month: 1, day: 1)
        return calendar.date(from: dateComponents)?.truncated ?? Date()
    }

    // MARK: - Tests
    func testTabBarController() {
        do {
            let tabBarController = TabBarController(
                trackerStore: try MockTrackerStore(dataStore: dataStore),
                scheduleStore: try ScheduleStore(dataStore: dataStore),
                recordStore: try RecordStore(dataStore: dataStore),
                categoryStore: try CategoryStore(dataStore),
                statisticStore: try StatisticStore(dataStore: dataStore),
                analyticsService: analyticsService
            )
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

            assertSnapshot(of: tabBarController, as: .image(traits: .init(userInterfaceStyle: .light)))
            assertSnapshot(of: tabBarController, as: .image(traits: .init(userInterfaceStyle: .dark)))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
