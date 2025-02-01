//
//  DataStore.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.11.2024.
//  Description: This file contains the DataStore class, which handles low-level tasks
//               for working with the NSManagedObjectContext context, such as creating a context,
//               saving and deleting records in the context
//

import CoreData

protocol DataStoreProtocol {
    var managedObjectContext: NSManagedObjectContext? { get }
    func saveContext() throws
    func deleteItem(_ item: NSManagedObject) throws
}

enum DataStoreError: Error {
    case modelNotFound
    case failedToLoadPersistentContainer(Error)
    case unexpectedNilResult
    case failedToSave(Error)
    case dataCorruption
    case delegateNotFound

    var userFriendlyMessage: String {
        switch self {
        case .failedToSave:
            return "Не удалось сохранить данные. Попробуйте еще раз."
        case .unexpectedNilResult:
            return "Внутренняя ошибка. Перезапустите приложение."
        case .dataCorruption:
            return "Данные повреждены. Попробуйте переустановить приложение."
        case .delegateNotFound, .failedToLoadPersistentContainer, .modelNotFound:
            return "Не удалось получить данные. Попробуйте еще раз."
        }
    }
}

final class DataStore {
    private let modelName = "Tracker"
    private static let storeURL: URL = {
        NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("data-store.sqlite")
    }()
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    init() throws {
        guard let modelUrl = Bundle(for: DataStore.self).url(forResource: modelName, withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelUrl)
        else {
            throw DataStoreError.modelNotFound
        }

        do {
            container = try NSPersistentContainer.load(
                name: modelName,
                model: model,
                url: DataStore.storeURL
            )
            context = container.newBackgroundContext()
        } catch {
            throw DataStoreError.failedToLoadPersistentContainer(error)
        }
    }

    func performSync<R>(_ action: (NSManagedObjectContext) throws -> R) throws -> R {
        let context = self.context
        var result: R?
        var caughtError: Error?

        context.performAndWait {
            do {
                result = try action(context)
            } catch {
                caughtError = error
            }
        }

        if let error = caughtError { throw error }
        guard let value = result else { throw DataStoreError.unexpectedNilResult }
        return value
    }

    func performSync(_ action: (NSManagedObjectContext) throws -> Void) throws {
        let context = self.context
        var caughtError: Error?

        context.performAndWait {
            do {
                try action(context)
            } catch {
                caughtError = error
            }
        }

        if let error = caughtError { throw error }
    }

    private func cleanUpReferencesToPersistentStores() {
        let coordinator = container.persistentStoreCoordinator
        DispatchQueue.global(qos: .background).async {
            for store in coordinator.persistentStores {
                do {
                    try coordinator.destroyPersistentStore(at: DataStore.storeURL, ofType: store.type, options: nil)
                } catch {
                    print("Failed to destroy persistent store: \(error)")
                }
            }
        }
    }

    deinit {
        cleanUpReferencesToPersistentStores()
    }
}

// MARK: - DataStoreProtocol
extension DataStore: DataStoreProtocol {
    var managedObjectContext: NSManagedObjectContext? {
        context
    }

    func saveContext() throws {
        do {
            try performSync { context in
                if context.hasChanges {
                    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                    try context.save()
                }
            }
        } catch {
            throw DataStoreError.failedToSave(error)
        }
    }

    func deleteItem(_ item: NSManagedObject) throws {
        try performSync { context in
            if item.managedObjectContext == context {
                context.delete(item)
            }
        }
    }
}
