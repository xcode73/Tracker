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
                #keyPath(Tracker.records), #keyPath(Record.date), date as NSDate
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
//        static func byTrackerId(_ trackerId: UUID) -> NSPredicate {
//            return NSPredicate(format: "%K == %@", #keyPath(Record.tracker.trackerId), trackerId as CVarArg)
//        }
    }
}

private extension PredicateFactory {
    static func bySearchText(_ searchText: String) -> NSPredicate {
        NSPredicate(
            format: "%K CONTAINS[cd] %@",
            #keyPath(Tracker.title), searchText
        )
    }

    static func byDate(_ date: Date) -> NSPredicate {
        NSPredicate(
            format: "%K == %@",
            #keyPath(Tracker.date), date as NSDate
        )
    }

    static func bySchedule(_ date: Date) -> NSPredicate {
        let weekday = WeekDay(date: date)
        return NSPredicate(
            format: "ANY %K.%K == %lld",
            #keyPath(Tracker.schedule), #keyPath(Schedule.weekDay), weekday.rawValue
        )
    }

    static func byRecords(_ date: Date) -> NSPredicate {
        NSPredicate(
            format: "SUBQUERY(%K, $record, $record.%K == %@).@count == 0",
            #keyPath(Tracker.records),
            #keyPath(Record.date),
            date as NSDate
        )
    }
}
