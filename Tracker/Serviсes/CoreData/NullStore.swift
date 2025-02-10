//
//  NullStore.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.11.2024.
//

import CoreData

final class NullStore {}

extension NullStore: DataStoreProtocol {
    var managedObjectContext: NSManagedObjectContext? { nil }
    func saveContext() throws {}
    func deleteItem(_ item: NSManagedObject) throws {}
}
