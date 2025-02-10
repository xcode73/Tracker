//
//  CategoryCoraData.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 21.11.2024.
//
//

import CoreData

@objc(CategoryCoraData)
public class CategoryCoraData: NSManagedObject, Identifiable {
    @NSManaged public var title: String
    @NSManaged public var categoryId: UUID
    @NSManaged public var trackers: NSSet?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryCoraData> {
        return NSFetchRequest<CategoryCoraData>(entityName: "CategoryCoraData")
    }
}

extension CategoryCoraData {
    func update(from categoryUI: CategoryUI, in context: NSManagedObjectContext) {
        self.categoryId = categoryUI.id
        self.title = categoryUI.title

        var existingTrackers = self.trackers as? Set<TrackerCoreData> ?? []

        for trackerUI in categoryUI.trackers {
            if let tracker = existingTrackers.first(where: { $0.trackerId == trackerUI.id }) {
                tracker.update(from: trackerUI, category: self, in: context)
                existingTrackers.remove(tracker)
            } else {
                let tracker = TrackerCoreData(context: context)
                tracker.update(from: trackerUI, category: self, in: context)
            }
        }

        for tracker in existingTrackers {
            context.delete(tracker)
        }
    }
}
