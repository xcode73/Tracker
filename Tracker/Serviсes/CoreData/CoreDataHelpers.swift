//
//  CoreDataHelpers.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.11.2024.
//

import CoreData

extension NSPersistentContainer {
    static func load(
        name: String,
        model: NSManagedObjectModel,
        url: URL
    ) throws -> NSPersistentContainer {
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]

        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw $0 }

        return container
    }
}
