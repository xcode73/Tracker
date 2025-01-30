//
//  Tracker.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 21.11.2024.
//
//

import CoreData

@objc(Tracker)
public class Tracker: NSManagedObject, Identifiable {
    @NSManaged public var color: String
    @NSManaged public var date: Date?
    @NSManaged public var emoji: String
    @NSManaged public var title: String
    @NSManaged public var trackerId: UUID
    @NSManaged public var category: TrackerCategoryCoreData
    @NSManaged public var records: NSSet?
    @NSManaged public var schedule: NSSet?
}
