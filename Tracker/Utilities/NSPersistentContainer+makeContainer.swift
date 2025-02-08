//
//  NSPersistentContainer+makeContainer.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.11.2024.
//

import CoreData

extension NSPersistentContainer {
    static func makeContainer(name: String, useInMemoryStore: Bool = false) throws -> NSPersistentContainer {
        guard let modelURL = Bundle.main.url(forResource: name, withExtension: "momd") else {
            fatalError("Не удалось найти модель \(name).momd в Bundle")
        }

        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Не удалось загрузить модель данных по URL: \(modelURL)")
        }

        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        let description: NSPersistentStoreDescription

        if useInMemoryStore {
            description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let storeURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("\(name).sqlite")
            description = NSPersistentStoreDescription(url: storeURL)
        }

        container.persistentStoreDescriptions = [description]

        var loadError: Error?
        container.loadPersistentStores { _, error in
            if let error = error { loadError = error }
        }
        if let error = loadError { throw error }

        return container
    }
}
