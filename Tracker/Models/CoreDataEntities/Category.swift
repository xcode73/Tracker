//
//  Category.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 21.11.2024.
//
//

import CoreData

@objc(Category)
public class Category: NSManagedObject, Identifiable {
    @NSManaged public var title: String
    @NSManaged public var categoryId: UUID
    @NSManaged public var trackers: NSSet?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }
}

extension Category {
    func update(from categoryUI: CategoryUI, in context: NSManagedObjectContext) {
        self.categoryId = categoryUI.id
        self.title = categoryUI.title

        var existingTrackers = self.trackers as? Set<Tracker> ?? []

        for trackerUI in categoryUI.trackers {
            if let tracker = existingTrackers.first(where: { $0.trackerId == trackerUI.id }) {
                tracker.update(from: trackerUI, category: self, in: context)
                existingTrackers.remove(tracker)
            } else {
                let tracker = Tracker(context: context)
                tracker.update(from: trackerUI, category: self, in: context)
            }
        }

        for tracker in existingTrackers {
            context.delete(tracker)
        }
    }
}
