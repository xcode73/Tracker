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
    func addTracker(tracker: TrackerUI, category: Category) throws {}
    func addCategory(category: CategoryUI) throws {}
    func saveContext() throws {}
    func refresh() throws {}
    func deleteItem(_ item: NSManagedObject) throws {}
}
