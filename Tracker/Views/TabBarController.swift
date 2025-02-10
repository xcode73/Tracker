//
//  TabBarController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.09.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    private let trackerStore: TrackerStoreProtocol
    private let scheduleStore: ScheduleStoreProtocol
    private let recordStore: RecordStoreProtocol
    private let categoryStore: CategoryStoreProtocol
    private let statisticStore: StatisticStoreProtocol
    private let analyticsService: AnalyticsServiceProtocol

    // MARK: - UI Components
    private lazy var trackersTabBarItem: UITabBarItem = {
        let view = UITabBarItem()
        view.title = NSLocalizedString("vcTitleTrackers", comment: "")
        view.image = .icTrackers
        view.selectedImage = nil
        return view
    }()

    private lazy var statisticsTabBarItem: UITabBarItem = {
        let view = UITabBarItem()
        view.title = NSLocalizedString("vcTitleStatistics", comment: "")
        view.image = .icStats
        view.selectedImage = nil
        return view
    }()

    init(
        trackerStore: TrackerStoreProtocol,
        scheduleStore: ScheduleStoreProtocol,
        recordStore: RecordStoreProtocol,
        categoryStore: CategoryStoreProtocol,
        statisticStore: StatisticStoreProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.trackerStore = trackerStore
        self.scheduleStore = scheduleStore
        self.recordStore = recordStore
        self.categoryStore = categoryStore
        self.statisticStore = statisticStore
        self.analyticsService = analyticsService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypWhite

        setupTabBar()
        setupTabs()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            tabBar.addTopBorder(color: .ypTabBarBorder, height: 1)
        }
    }

    private func setupTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypWhite
        appearance.backgroundEffect = .none
        appearance.backgroundImage = UIImage()
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        tabBar.addTopBorder(color: .ypTabBarBorder, height: 1)
    }

    private func setupTabs() {
        let trackersViewController = TrackersViewController(
            trackerStore: trackerStore,
            scheduleStore: scheduleStore,
            recordStore: recordStore,
            categoryStore: categoryStore,
            analyticsService: analyticsService
        )
        trackersViewController.title = NSLocalizedString("vcTitleTrackers", comment: "")
        let trackerNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackersViewController.tabBarItem = trackersTabBarItem

        let statisticViewController = StatisticViewController(
            statisticStore: statisticStore,
            analyticsService: analyticsService
        )
        statisticViewController.title = NSLocalizedString("vcTitleStatistics", comment: "")
        let statNavigationController = UINavigationController(rootViewController: statisticViewController)

        statNavigationController.tabBarItem = statisticsTabBarItem
        statNavigationController.navigationBar.prefersLargeTitles = true

        self.viewControllers = [
            trackerNavigationController,
            statNavigationController
        ]
    }

    // MARK: - Alerts
    func showStoreErrorAlert(_ message: String) {
        let model = AlertModel(
            title: NSLocalizedString("alertTitleStoreError", comment: ""),
            message: message,
            buttons: [.cancelButton],
            identifier: "Tracker Store Error Alert",
            completion: nil
        )

        AlertPresenter.showAlert(on: self, model: model)
    }
}
