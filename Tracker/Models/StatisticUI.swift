//
//  StatisticUI.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 05.02.2025.
//

import Foundation

struct StatisticUI {
    let statisticId: Int
    let title: String
    let value: Int

    init(statisticId: Int, title: String, value: Int) {
        self.statisticId = statisticId
        self.title = title
        self.value = value
    }

    init(from entity: StatisticCoreData) {
        self.statisticId = Int(entity.statisticId)
        self.title = entity.title
        self.value = Int(entity.value)
    }
}
