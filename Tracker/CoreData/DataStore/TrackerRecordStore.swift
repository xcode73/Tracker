//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.11.2024.
//

import CoreData

protocol TrackerRecordStoreProtocol {
    func addRecord(_ record: TrackerRecord) throws
    func deleteRecord(_ record: TrackerRecord) throws
    func recordObject(for trackerId: UUID, date: Date) -> TrackerRecord?
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
    func recordObject(for trackerId: UUID, date: Date) -> TrackerRecord? {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        #keyPath(TrackerRecordCoreData.trackerId), trackerId as NSUUID,
                                        #keyPath(TrackerRecordCoreData.date), date as NSDate)

        guard let record = try? context.fetch(request).first else { return nil }

        return TrackerRecord(trackerId: record.trackerId, date: record.date)
    }

    func recordsCount(for trackerId: UUID) -> Int? {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(TrackerRecordCoreData.trackerId),
                                        trackerId as NSUUID)

        return try? context.count(for: request)
    }

    func addRecord(_ record: TrackerRecord) throws {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(TrackerCoreData.trackerId),
                                        record.trackerId as NSUUID)
        guard let storedTracker = try? context.fetch(request).first else { return }

        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.date = record.date
        recordCoreData.trackerId = record.trackerId
        recordCoreData.tracker = storedTracker

        try? dataStore.saveContext()
    }

    func deleteRecord(_ record: TrackerRecord) throws {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        #keyPath(TrackerRecordCoreData.trackerId),
                                        record.trackerId as NSUUID,
                                        #keyPath(TrackerRecordCoreData.date),
                                        record.date as NSDate)
        guard let storedRecord = try? context.fetch(request).first else { return }

        try? dataStore.deleteItem(storedRecord)
        try? dataStore.saveContext()
    }
}
