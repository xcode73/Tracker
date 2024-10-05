//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 25.09.2024.
//

import Foundation

// сущность для хранения трекеров по категориям.
// имеет заголовок и содержит массив трекеров, относящихся к этой категории.
struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}
