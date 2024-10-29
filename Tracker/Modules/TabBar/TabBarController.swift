//
//  TabBarController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.09.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    private enum LocalConst {
        static let trackers = "Трекеры"
        static let statistic = "Статистика"
    }

    // MARK: - UI Components
    private lazy var trackersTabBarItem: UITabBarItem = {
        let view = UITabBarItem()
        view.title = LocalConst.trackers
        view.image = .icTrackers
        view.selectedImage = nil
        
        return view
    }()
    
    private lazy var statisticsTabBarItem: UITabBarItem = {
        let view = UITabBarItem()
        view.title = LocalConst.statistic
        view.image = .icStats
        view.selectedImage = nil
        
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabs()
        //Set the background color
        UITabBar.appearance().backgroundColor = .ypWhite
        tabBar.isTranslucent = false
    }
    
    private func setupTabs() {
        // Trackers Tab
        let trackersViewController = TrackersViewController()
        trackersViewController.title = LocalConst.trackers
        let trackerNavigationController = UINavigationController(rootViewController: trackersViewController)

        
        trackerNavigationController.navigationBar.prefersLargeTitles = true
        trackerNavigationController.navigationItem.largeTitleDisplayMode = .always
        
        trackersViewController.tabBarItem = trackersTabBarItem
        
        // Statistic Tab
        let statisticViewController = StatisticViewController()
        statisticViewController.title = LocalConst.statistic
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

