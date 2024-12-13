//
//  DataStore.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.11.2024.
//

import CoreData

protocol TrackerDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func addTracker(tracker: Tracker, category: TrackerCategoryCoreData) throws
    func addCategory(category: TrackerCategory) throws
    func saveContext() throws
    func refresh() throws
    func deleteItem(_ item: NSManagedObject) throws
}

class DataStore {
    private let modelName = "Tracker"
    private let storeURL = NSPersistentContainer
                                .defaultDirectoryURL()
                                .appendingPathComponent("data-store.sqlite")
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    init() throws {
        guard let modelUrl = Bundle(for: DataStore.self).url(forResource: modelName, withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelUrl)
        else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }
    
    func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
}

// MARK: - TrackerDataStore
extension DataStore: TrackerDataStore {
    var managedObjectContext: NSManagedObjectContext? {
        context
    }
    
    func saveContext() throws {
        try performSync { context in
            Result {
                try context.save()
            }
        }
    }
    
    func refresh() throws {
        try performSync { context in
            Result {
                context.refreshAllObjects()
            }
        }
    }
    
    func deleteItem(_ item: NSManagedObject) throws {
        try performSync { context in
            Result {
                context.delete(item)
            }
        }
    }

    func addTracker(tracker: Tracker, category: TrackerCategoryCoreData) throws {
        try performSync { context in
            Result {
                context.refreshAllObjects()
                
                let trackerCoreData = TrackerCoreData(context: context)
                trackerCoreData.trackerId = tracker.id
                trackerCoreData.title = tracker.title
                trackerCoreData.emoji = tracker.emoji
                trackerCoreData.color = tracker.color
                trackerCoreData.date = tracker.date
                trackerCoreData.category = category
                
                try context.save()
            }
        }
    }

    func addCategory(category: TrackerCategory) throws {
        try performSync { context in
            Result {
                let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
                trackerCategoryCoreData.title = category.title
                try context.save()
            }
        }
    }
}
