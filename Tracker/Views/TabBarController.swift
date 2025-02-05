//
//  TabBarController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.09.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    private let analyticsService: AnalyticsServiceProtocol
    private let dataStore = Constants.appDelegate().trackerDataStore
    private var trackerStore: TrackerStore?
    private var statisticStore: StatisticStore?

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

    init(analyticsService: AnalyticsServiceProtocol) {
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

        setupTrackerStore()
        setupStatisticStore()
        setupTabBar()
        setupTabs()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            tabBar.addTopBorder(color: .ypTabBarBorder, height: 1)
        }
    }

    private func setupTrackerStore() {
        do {
            trackerStore = try TrackerStore(dataStore: dataStore)
        } catch {
            let trackerError = error as? StatisticStoreError
            showStoreErrorAlert(
                trackerError?.userFriendlyMessage ?? error.localizedDescription
            )
        }
    }

    private func setupStatisticStore() {
        do {
            statisticStore = try StatisticStore(dataStore: dataStore)
        } catch {
            let statError = error as? StatisticStoreError
            showStoreErrorAlert(
                statError?.userFriendlyMessage ?? error.localizedDescription
            )
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
        guard
            let trackerStore,
            let statisticStore
        else {
            showStoreErrorAlert(
                NSLocalizedString("alertTitleStoreError", comment: "")
            )
            return
        }

        // Trackers Tab
        let trackersViewController = TrackersViewController(
            dataStore: dataStore,
            trackerStore: trackerStore,
            analyticsService: analyticsService
        )
        trackersViewController.title = NSLocalizedString("vcTitleTrackers", comment: "")
        let trackerNavigationController = UINavigationController(rootViewController: trackersViewController)

        trackersViewController.tabBarItem = trackersTabBarItem
        trackerStore.delegate = trackersViewController

        // Statistic Tab
        let statisticViewController = StatisticViewController(
            statisticStore: statisticStore,
            analyticsService: analyticsService
        )
        statisticViewController.title = NSLocalizedString("vcTitleStatistics", comment: "")
        let statNavigationController = UINavigationController(rootViewController: statisticViewController)

        statNavigationController.tabBarItem = statisticsTabBarItem
        statNavigationController.navigationBar.prefersLargeTitles = true
        statisticStore.delegate = statisticViewController

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

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("TabController") {
    let analyticsService = AnalyticsService()
    TabBarController(analyticsService: analyticsService)
}
#endif
