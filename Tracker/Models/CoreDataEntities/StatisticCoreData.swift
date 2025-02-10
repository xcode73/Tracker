//
//  StatisticCoreData.swift
//  
//
//  Created by Nikolai Eremenko on 05.02.2025.
//
//

import CoreData

@objc(StatisticCoreData)
public class StatisticCoreData: NSManagedObject {
    @NSManaged public var statisticId: Int64
    @NSManaged public var title: String
    @NSManaged public var value: Int64

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StatisticCoreData> {
        return NSFetchRequest<StatisticCoreData>(entityName: "StatisticCoreData")
    }
}

extension StatisticCoreData {
    func update(from statisticUI: StatisticUI, in context: NSManagedObjectContext) {
        self.statisticId = Int64(statisticUI.statisticId)
        self.title = statisticUI.title
        self.value = Int64(statisticUI.value)
    }
}
