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
    func fetchRecord(for trackerUI: TrackerUI, date: Date) throws -> RecordUI?
    func fetchNumberOfRecords(for trackerId: UUID) throws -> Int
}

enum RecordStoreError: Error {
    case failedToInitializeContext
    case failedToFindRecord

    var userFriendlyMessage: String {
        switch self {
        case .failedToInitializeContext:
            return "Не удалось получить данные. Попробуйте еще раз."
        case .failedToFindRecord:
            return "Запись не найдена"
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
    func fetchRecord(for trackerUI: TrackerUI, date: Date) throws -> RecordUI? {
        do {
            let fetchRequest: NSFetchRequest<RecordCoreData> = RecordCoreData.fetchRequest()
            fetchRequest.predicate = PredicateFactory.RecordPredicate.byTrackerIdAndDate(trackerUI.id, date: date)
            guard let record = try context.fetch(fetchRequest).first else { return nil }

            return RecordUI(from: record)
        } catch {
            throw error
        }
    }

    func fetchNumberOfRecords(for trackerId: UUID) throws -> Int {
        do {
            let fetchRequest: NSFetchRequest<RecordCoreData> = RecordCoreData.fetchRequest()
            fetchRequest.predicate = PredicateFactory.RecordPredicate.byId(trackerId)
            return try context.count(for: fetchRequest)
        } catch {
            throw error
        }
    }

    func addRecord(_ recordUI: RecordUI) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = PredicateFactory.TrackerPredicate.byId(recordUI.trackerId)
        guard
            let trackerCoreData = try context.fetch(fetchRequest).first
        else {
            throw TrackerStoreError.failedToFindTracker
        }

        do {
            let recordCoreData = RecordCoreData(context: context)
            recordCoreData.update(from: recordUI, tracker: trackerCoreData, in: context)

            try dataStore.saveContext()
        } catch {
            throw error
        }
    }

    func deleteRecord(_ record: RecordUI) throws {
        do {
            let fetchRequest: NSFetchRequest<RecordCoreData> = RecordCoreData.fetchRequest()
            fetchRequest.predicate = PredicateFactory.RecordPredicate.byTrackerIdAndDate(
                record.trackerId,
                date: record.date
            )
            guard
                let recordCoreData = try context.fetch(fetchRequest).first
            else {
                throw RecordStoreError.failedToFindRecord
            }

            try dataStore.deleteItem(recordCoreData)
            try dataStore.saveContext()
        } catch {
            throw error
        }
    }
}
