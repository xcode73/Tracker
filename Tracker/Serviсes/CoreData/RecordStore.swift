//
//  RecordStore.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.11.2024.
//

import CoreData

protocol RecordStoreProtocol {
    func addRecord(_ record: RecordUI) throws
    func deleteRecord(_ record: RecordUI) throws
    func recordObject(for trackerId: UUID, date: Date) -> RecordUI?
    func fetchNumberOfRecords(for trackerId: UUID) -> Int?
}

enum RecordStoreError: Error {
    case failedToInitializeContext

    var userFriendlyMessage: String {
        switch self {
        case .failedToInitializeContext:
            return "Не удалось получить данные. Попробуйте еще раз."
        }
    }
}

final class RecordStore: NSObject {
    private let context: NSManagedObjectContext
    private let dataStore: DataStoreProtocol

    init(
        dataStore: DataStoreProtocol
    ) throws {
        guard
            let context = dataStore.managedObjectContext
        else {
            throw RecordStoreError.failedToInitializeContext
        }

        self.context = context
        self.dataStore = dataStore
    }
}

// MARK: - RecordStoreProtocol
extension RecordStore: RecordStoreProtocol {
    func recordObject(for trackerId: UUID, date: Date) -> RecordUI? {
        let request = NSFetchRequest<RecordCoreData>(entityName: "RecordCoreData")
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        #keyPath(RecordCoreData.trackerId), trackerId as NSUUID,
                                        #keyPath(RecordCoreData.date), date as NSDate)

        guard let record = try? context.fetch(request).first else { return nil }

        return RecordUI(trackerId: record.trackerId, date: record.date)
    }

    func fetchNumberOfRecords(for trackerId: UUID) -> Int? {
        let request = NSFetchRequest<RecordCoreData>(entityName: "RecordCoreData")
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(RecordCoreData.trackerId),
                                        trackerId as NSUUID)

        return try? context.count(for: request)
    }

    func addRecord(_ record: RecordUI) throws {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(TrackerCoreData.trackerId),
                                        record.trackerId as NSUUID)
        guard let storedTracker = try? context.fetch(request).first else { return }

        let recordCoreData = RecordCoreData(context: context)
        recordCoreData.date = record.date
        recordCoreData.trackerId = record.trackerId
        recordCoreData.tracker = storedTracker

        try? dataStore.saveContext()
    }

    func deleteRecord(_ record: RecordUI) throws {
        let request = NSFetchRequest<RecordCoreData>(entityName: "RecordCoreData")
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        #keyPath(RecordCoreData.trackerId),
                                        record.trackerId as NSUUID,
                                        #keyPath(RecordCoreData.date),
                                        record.date as NSDate)
        guard let storedRecord = try? context.fetch(request).first else { return }

        try? dataStore.deleteItem(storedRecord)
        try? dataStore.saveContext()
    }
}
