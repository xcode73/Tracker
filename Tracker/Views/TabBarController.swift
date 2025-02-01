//
//  TabBarController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.09.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    private let dataStore = Constants.appDelegate().trackerDataStore
    private var selectedFilter: Filter = UserDefaults.standard.loadFilter()
    private var trackerStore: TrackerStore?

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

    private lazy var topBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        return view
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTrackerStore()
        setupTabBar()
        setupTabs()
    }

    // MARK: - Создание TrackerStore
    private func setupTrackerStore() {
        do {
            trackerStore = try TrackerStore(dataStore: dataStore, selectedFilter: selectedFilter)
        } catch {
            showStoreErrorAlert(NSLocalizedString("alertMessageTrackerStoreInitError", comment: ""))
        }
    }

    private func setupTabBar() {
        let appearance = self.tabBar.standardAppearance
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        appearance.backgroundEffect = nil
        appearance.backgroundColor = .ypWhite
        self.tabBar.standardAppearance = appearance
        self.tabBar.layer.borderColor = UIColor.ypGray.cgColor
        self.tabBar.layer.borderWidth = 1
    }

    private func setupTabs() {
        guard let trackerStore else { return }

        // Trackers Tab
        let trackersViewController = TrackersViewController(
            dataStore: dataStore,
            trackerStore: trackerStore,
            selectedFilter: selectedFilter
        )
        trackersViewController.title = NSLocalizedString("vcTitleTrackers", comment: "")
        let trackerNavigationController = UINavigationController(rootViewController: trackersViewController)

        trackerNavigationController.navigationBar.prefersLargeTitles = true
        trackerNavigationController.navigationItem.largeTitleDisplayMode = .always
        trackersViewController.tabBarItem = trackersTabBarItem
        trackerStore.delegate = trackersViewController

        // Statistic Tab
        let statisticViewController = StatisticViewController()
        statisticViewController.title = NSLocalizedString("vcTitleStatistics", comment: "")
        let statNavigationController = UINavigationController(rootViewController: statisticViewController)
        statNavigationController.navigationBar.prefersLargeTitles = true
        statNavigationController.tabBarItem = statisticsTabBarItem

        self.viewControllers = [trackerNavigationController, statNavigationController]
    }

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
    TabBarController()
}
#endif
