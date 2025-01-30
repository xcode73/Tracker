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

final class ScheduleStore: NSObject {
    enum ScheduleDataProviderError: Error {
        case failedToInitializeContext
    }

    private let context: NSManagedObjectContext
    private let dataStore: TrackerDataStore

    init(dataStore: TrackerDataStore) throws {
        guard
            let context = dataStore.managedObjectContext
        else {
            throw ScheduleDataProviderError.failedToInitializeContext
        }
        self.context = context
        self.dataStore = dataStore
    }
}

// MARK: - ScheduleStoreProtocol
extension ScheduleStore: ScheduleStoreProtocol {
    func addSchedule(to tracker: TrackerUI) throws {
        let request = NSFetchRequest<Tracker>(entityName: "Tracker")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Tracker.trackerId), tracker.id as NSUUID)

        guard
            let schedule = tracker.schedule,
            let storedTracker = try? context.fetch(request).first
        else {
            return
        }

        for day in schedule {
            let newScheduleCoreData = Schedule(context: context)
            newScheduleCoreData.tracker = storedTracker

            newScheduleCoreData.weekDay = day
        }

        try? dataStore.saveContext()
    }

    func deleteSchedule(for tracker: TrackerUI) throws {
        let request = NSFetchRequest<Tracker>(entityName: "Tracker")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Tracker.trackerId), tracker.id as NSUUID)

        guard let storedTracker = try? context.fetch(request).first else { return }

        if let storedSchedule = storedTracker.schedule {
            for _ in storedSchedule {
                let request = NSFetchRequest<Schedule>(entityName: "Schedule")
                request.predicate = NSPredicate(format: "%K == %@",
                                                #keyPath(Schedule.tracker.trackerId), tracker.id as NSUUID)
                guard let schedule = try? context.fetch(request).first else { continue }
                try? dataStore.deleteItem(schedule)
            }
        }

        try? dataStore.saveContext()
    }

    func getSchedule(for tracker: TrackerUI) -> [WeekDay]? {
        let request = NSFetchRequest<Schedule>(entityName: "Schedule")
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(Schedule.tracker.trackerId), tracker.id as NSUUID)

        guard let storedSchedule = try? context.fetch(request) else { return nil }

        let schedule = storedSchedule.map { $0.weekDay }

        return schedule
    }
}
