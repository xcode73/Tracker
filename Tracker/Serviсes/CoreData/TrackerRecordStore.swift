//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.11.2024.
//

import CoreData

protocol TrackerRecordStoreProtocol {
    func addRecord(_ record: RecordUI) throws
    func deleteRecord(_ record: RecordUI) throws
    func recordObject(for trackerId: UUID, date: Date) -> RecordUI?
    func recordsCount(for trackerId: UUID) -> Int?
}

final class TrackerRecordStore: NSObject {
    enum RecordDataProviderError: Error {
        case failedToInitializeContext
    }

    private let context: NSManagedObjectContext
    private let dataStore: TrackerDataStore

    init(dataStore: TrackerDataStore) throws {
        guard
            let context = dataStore.managedObjectContext
        else {
            throw RecordDataProviderError.failedToInitializeContext
        }

        self.context = context
        self.dataStore = dataStore
    }
}

extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func recordObject(for trackerId: UUID, date: Date) -> RecordUI? {
        let request = NSFetchRequest<Record>(entityName: "Record")
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        #keyPath(Record.trackerId), trackerId as NSUUID,
                                        #keyPath(Record.date), date as NSDate)

        guard let record = try? context.fetch(request).first else { return nil }

        return RecordUI(trackerId: record.trackerId, date: record.date)
    }

    func recordsCount(for trackerId: UUID) -> Int? {
        let request = NSFetchRequest<Record>(entityName: "Record")
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(Record.trackerId),
                                        trackerId as NSUUID)

        return try? context.count(for: request)
    }

    func addRecord(_ record: RecordUI) throws {
        let request = NSFetchRequest<Tracker>(entityName: "Tracker")
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(Tracker.trackerId),
                                        record.trackerId as NSUUID)
        guard let storedTracker = try? context.fetch(request).first else { return }

        let recordCoreData = Record(context: context)
        recordCoreData.date = record.date
        recordCoreData.trackerId = record.trackerId
        recordCoreData.tracker = storedTracker

        try? dataStore.saveContext()
    }

    func deleteRecord(_ record: RecordUI) throws {
        let request = NSFetchRequest<Record>(entityName: "Record")
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        #keyPath(Record.trackerId),
                                        record.trackerId as NSUUID,
                                        #keyPath(Record.date),
                                        record.date as NSDate)
        guard let storedRecord = try? context.fetch(request).first else { return }

        try? dataStore.deleteItem(storedRecord)
        try? dataStore.saveContext()
    }
}
