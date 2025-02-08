//
//  Tracker.swift
//  TrackerCoreData
//
//  Created by Nikolai Eremenko on 21.11.2024.
//
//

import CoreData

@objc(TrackerCoreData)
public class TrackerCoreData: NSManagedObject, Identifiable {
    @NSManaged public var color: String
    @NSManaged public var date: Date?
    @NSManaged public var emoji: String
    @NSManaged public var title: String
    @NSManaged public var trackerId: UUID
    @NSManaged public var sectionTitle: String
    @NSManaged public var isPinned: Bool
    @NSManaged public var category: CategoryCoraData
    @NSManaged public var records: NSSet?
    @NSManaged public var schedule: NSSet?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }
}

extension TrackerCoreData {
    func update(from trackerUI: TrackerUI, category: CategoryCoraData, in context: NSManagedObjectContext) {
        self.trackerId = trackerUI.id
        self.title = trackerUI.title
        self.color = trackerUI.color
        self.emoji = trackerUI.emoji
        self.isPinned = trackerUI.isPinned
        self.date = trackerUI.date
        self.category = category
        self.sectionTitle = isPinned ? NSLocalizedString("sectionHeaderPinned", comment: "") : (category.title)

        if let existingSchedules = self.schedule as? Set<ScheduleCoreData> {
            for schedule in existingSchedules {
                context.delete(schedule)
            }
        }

        if let newSchedule = trackerUI.schedule {
            for weekDay in newSchedule {
                let schedule = ScheduleCoreData(context: context)
                schedule.weekDay = weekDay
                schedule.tracker = self
            }
        }
    }
}
