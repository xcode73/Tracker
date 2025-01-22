//
//  TabBarController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.09.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    private enum LocalConst {
        static let trackers = NSLocalizedString("tabBar.trackers", comment: "")
        static let statistic = NSLocalizedString("tabBar.statistics", comment: "")
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
    
    private lazy var topBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
        setupTabs()
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
#if DEBUG
@available(iOS 17, *)
#Preview("TabController") {
    TabBarController()
}
#endif
