//
//  TabBarController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.09.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    private let dataStore = Constants.appDelegate().trackerDataStore
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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypWhite

        setupTrackerStore()
        setupTabBar()
        setupTabs()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            tabBar.addTopBorder(color: .ypTabBarBorder, height: 1)
        }
    }

    // MARK: - Создание TrackerStore
    private func setupTrackerStore() {
        do {
            trackerStore = try TrackerStore(dataStore: dataStore)
        } catch {
            showStoreErrorAlert(NSLocalizedString("alertMessageTrackerStoreInitError", comment: ""))
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
        guard let trackerStore else { return }

        // Trackers Tab
        let trackersViewController = TrackersViewController(
            dataStore: dataStore,
            trackerStore: trackerStore
        )
        trackersViewController.title = NSLocalizedString("vcTitleTrackers", comment: "")
        let trackerNavigationController = UINavigationController(rootViewController: trackersViewController)

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
