//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 23.09.2024.
//

import UIKit

class StatisticViewController: UIViewController {
    let analyticsService: AnalyticsServiceProtocol

    init(analyticsService: AnalyticsServiceProtocol) {
        self.analyticsService = analyticsService

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
