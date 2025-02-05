//
//  Record.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 21.11.2024.
//
//

import CoreData

@objc(Record)
public class Record: NSManagedObject, Identifiable {
    @NSManaged public var date: Date
    @NSManaged public var trackerId: UUID
    @NSManaged public var tracker: Tracker

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Record> {
        return NSFetchRequest<Record>(entityName: "Record")
    }
}
