//
//  RecordCoreData.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 21.11.2024.
//
//

import CoreData

@objc(RecordCoreData)
public class RecordCoreData: NSManagedObject, Identifiable {
    @NSManaged public var date: Date
    @NSManaged public var trackerId: UUID
    @NSManaged public var tracker: TrackerCoreData

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecordCoreData> {
        return NSFetchRequest<RecordCoreData>(entityName: "RecordCoreData")
    }
}

extension RecordCoreData {
    func update(from recordUI: RecordUI, tracker: TrackerCoreData, in context: NSManagedObjectContext) {
        self.date = recordUI.date
        self.trackerId = recordUI.trackerId
        self.tracker = tracker
    }
}
