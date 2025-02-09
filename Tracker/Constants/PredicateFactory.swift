//
//  PredicateFactory.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 01.02.2025.
//

import CoreData

enum PredicateFactory {
    enum TrackerPredicate {
        static func search(date: Date, searchText: String) -> NSPredicate {
            NSCompoundPredicate(
                orPredicateWithSubpredicates: [
                    NSCompoundPredicate(
                        andPredicateWithSubpredicates: [
                            byDate(date),
                            bySearchText(searchText)
                        ]
                    ),
                    NSCompoundPredicate(
                        andPredicateWithSubpredicates: [
                            bySchedule(date),
                            bySearchText(searchText)
                        ]
                    )
                ]
            )
        }

        static func all(_ date: Date) -> NSPredicate {
            NSCompoundPredicate(
                orPredicateWithSubpredicates: [
                    byDate(date),
                    bySchedule(date)
                ]
            )
        }

        static func completed(on date: Date) -> NSPredicate {
            NSPredicate(
                format: "ANY %K.%K == %@",
                #keyPath(TrackerCoreData.records), #keyPath(RecordCoreData.date), date as NSDate
            )
        }

        static func notCompleted(_ date: Date) -> NSPredicate {
            NSCompoundPredicate(
                orPredicateWithSubpredicates: [
                    NSCompoundPredicate(
                        andPredicateWithSubpredicates: [
                            byDate(date),
                            byRecords(date)
                        ]
                    ),
                    NSCompoundPredicate(
                        andPredicateWithSubpredicates: [
                            bySchedule(date),
                            byRecords(date)
                        ]
                    )
                ]
            )
        }

        static func byId(_ id: UUID) -> NSPredicate {
            NSPredicate(format: "trackerId == %@", id as CVarArg)
        }
    }

    enum CategoryPredicate {
        static func byId(_ id: UUID) -> NSPredicate {
            NSPredicate(format: "categoryId == %@", id as CVarArg)
        }
    }

    enum RecordPredicate {
        static func byId(_ id: UUID) -> NSPredicate {
            NSPredicate(format: "%K == %@", #keyPath(RecordCoreData.trackerId), id as NSUUID)
        }

        static func byDate(_ date: Date) -> NSPredicate {
            NSPredicate(format: "%K == %@", #keyPath(RecordCoreData.date), date as NSDate)
        }

        static func byTrackerIdAndDate(_ id: UUID, date: Date) -> NSPredicate {
            NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    byId(id),
                    byDate(date)
                ]
            )
        }
    }
}

private extension PredicateFactory {
    static func bySearchText(_ searchText: String) -> NSPredicate {
        NSPredicate(
            format: "%K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.title), searchText
        )
    }

    static func byDate(_ date: Date) -> NSPredicate {
        NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCoreData.date), date as NSDate
        )
    }

    static func bySchedule(_ date: Date) -> NSPredicate {
        let weekday = WeekDay(date: date)
        return NSPredicate(
            format: "ANY %K.%K == %lld",
            #keyPath(TrackerCoreData.schedule), #keyPath(ScheduleCoreData.weekDay), weekday.rawValue
        )
    }

    static func byRecords(_ date: Date) -> NSPredicate {
        NSPredicate(
            format: "SUBQUERY(%K, $record, $record.%K == %@).@count == 0",
            #keyPath(TrackerCoreData.records),
            #keyPath(RecordCoreData.date),
            date as NSDate
        )
    }
}
