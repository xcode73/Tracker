//
//  ScheduleStore.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 10.12.2024.
//

import CoreData

protocol ScheduleStoreProtocol {
    func addSchedule(to tracker: TrackerUI) throws
    func deleteSchedule(for tracker: TrackerUI) throws
    func getSchedule(for tracker: TrackerUI) -> [WeekDay]?
}

enum ScheduleStoreError: Error {
    case failedToInitializeContext

    var userFriendlyMessage: String {
        switch self {
        case .failedToInitializeContext:
            return "Не удалось получить данные. Попробуйте еще раз."
        }
    }
}

final class ScheduleStore: NSObject {
    private let context: NSManagedObjectContext
    private let dataStore: DataStoreProtocol

    init(dataStore: DataStoreProtocol) throws {
        guard
            let context = dataStore.managedObjectContext
        else {
            throw ScheduleStoreError.failedToInitializeContext
        }
        self.context = context
        self.dataStore = dataStore
    }
}

// MARK: - ScheduleStoreProtocol
extension ScheduleStore: ScheduleStoreProtocol {
    func addSchedule(to tracker: TrackerUI) throws {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "Tracker")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerId), tracker.id as NSUUID)

        guard
            let schedule = tracker.schedule,
            let storedTracker = try? context.fetch(request).first
        else {
            return
        }

        for day in schedule {
            let newScheduleCoreData = ScheduleCoreData(context: context)
            newScheduleCoreData.tracker = storedTracker

            newScheduleCoreData.weekDay = day
        }

        try? dataStore.saveContext()
    }

    func deleteSchedule(for tracker: TrackerUI) throws {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "Tracker")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerId), tracker.id as NSUUID)

        guard let storedTracker = try? context.fetch(request).first else { return }

        if let storedSchedule = storedTracker.schedule {
            for _ in storedSchedule {
                let request = NSFetchRequest<ScheduleCoreData>(entityName: "ScheduleCoreData")
                request.predicate = NSPredicate(format: "%K == %@",
                                                #keyPath(ScheduleCoreData.tracker.trackerId), tracker.id as NSUUID)
                guard let schedule = try? context.fetch(request).first else { continue }
                try? dataStore.deleteItem(schedule)
            }
        }

        try? dataStore.saveContext()
    }

    func getSchedule(for tracker: TrackerUI) -> [WeekDay]? {
        let request = NSFetchRequest<ScheduleCoreData>(entityName: "ScheduleCoreData")
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(ScheduleCoreData.tracker.trackerId), tracker.id as NSUUID)

        guard let storedSchedule = try? context.fetch(request) else { return nil }

        let schedule = storedSchedule.map { $0.weekDay }

        return schedule
    }
}
