//
//  Schedule.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 10.12.2024.
//
//

import CoreData

@objc(Schedule)
public class Schedule: NSManagedObject, Identifiable {
    @NSManaged public var weekDay: WeekDay
    @NSManaged public var tracker: Tracker
}
