//
//  TabBarController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.09.2024.
//

import UIKit

private enum Titles {
    static let trackers = "Трекеры"
    static let statistic = "Статистика"
}

final class TabBarController: UITabBarController {

    // MARK: - UI Components
    private lazy var trackersTabBarItem: UITabBarItem = {
        let view = UITabBarItem()
        view.title = Titles.trackers
        view.image = .icTrackers
        view.selectedImage = nil
        view.accessibilityIdentifier = "Trackers Tab"
        
        return view
    }()
    
    private lazy var statisticsTabBarItem: UITabBarItem = {
        let view = UITabBarItem()
        view.title = Titles.statistic
        view.image = .icStats
        view.selectedImage = nil
        view.accessibilityIdentifier = "Statistics Tab"
        
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabs()
    }
    
    private func setupTabs() {
        // Trackers Tab
        let trackerViewController = TrackersViewController()
        trackerViewController.title = Titles.trackers
        let trackerNavigationController = UINavigationController(rootViewController: trackerViewController)
        trackerNavigationController.navigationBar.prefersLargeTitles = true
        trackerViewController.tabBarItem = trackersTabBarItem
        
        // Statistic Tab
        let statisticViewController = StatisticViewController()
        statisticViewController.title = Titles.statistic
        let statNavigationController = UINavigationController(rootViewController: statisticViewController)
        statNavigationController.navigationBar.prefersLargeTitles = true
        statNavigationController.tabBarItem = statisticsTabBarItem
        
        self.viewControllers = [trackerNavigationController, statNavigationController]
    }
}

// MARK: - Preview
@available(iOS 17, *)
#Preview("TabController") {
    TabBarController()
}

