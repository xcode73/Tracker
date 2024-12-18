//
//  NullStore.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.11.2024.
//

import CoreData

final class NullStore {}

extension NullStore: TrackerDataStore {
    var managedObjectContext: NSManagedObjectContext? { nil }
    func addTracker(tracker: Tracker, category: TrackerCategoryCoreData) throws {}
    func addCategory(category: TrackerCategory) throws {}
    func saveContext() throws {}
    func refresh() throws {}
    func deleteItem(_ item: NSManagedObject) throws {}
}
