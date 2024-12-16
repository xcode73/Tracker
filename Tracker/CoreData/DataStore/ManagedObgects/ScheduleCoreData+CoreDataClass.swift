//
//  ScheduleCoreData.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 10.12.2024.
//
//

import Foundation
import CoreData

@objc(ScheduleCoreData)
public class ScheduleCoreData: NSManagedObject, Identifiable {
    @NSManaged public var weekDay: WeekDay
    @NSManaged public var tracker: TrackerCoreData
}
