//
//  StatisticStore.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 05.02.2025.
//

import CoreData

protocol StatisticStoreProtocol {
    var delegate: StatisticStoreDelegate? { get set }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func setupStatisticStore() throws
    func fetchStatisticUI(at indexPath: IndexPath) -> StatisticUI
    func calculateStatistics() throws
    func fetchNumberOfRecords() throws -> Int
}

protocol StatisticStoreDelegate: AnyObject {
    func didUpdate(_ updates: [StatisticStoreUpdate])
}

enum StatisticStoreUpdate: Hashable {
    case inserted(at: IndexPath)
    case deleted(from: IndexPath)
    case updated(at: IndexPath)
    case moved(from: IndexPath, to: IndexPath)
}

enum StatisticStoreError: Error {
    case failedToInitializeContext
    case failedToFindStatistic
    case statisticAlreadyExists

    var userFriendlyMessage: String {
        switch self {
        case .failedToInitializeContext:
            return "Не удалось получить данные. Попробуйте еще раз."
        case .failedToFindStatistic:
            return "Не удалось получить данные. Попробуйте переустановить приложение."
        case .statisticAlreadyExists:
            return "Не удалось запустить приложение. Попробуйте переустановить."
        }
    }
}

struct StatisticValues {
    let bestPeriod: Int
    let perfectDays: Int
    let completedTrackers: Int
    let averageValue: Int
}

final class StatisticStore: NSObject {
    // MARK: - Properties
    weak var delegate: StatisticStoreDelegate?
    var inProgressChanges: [StatisticStoreUpdate] = []

    private let context: NSManagedObjectContext
    private let dataStore: DataStoreProtocol

    private lazy var fetchedResultsController: NSFetchedResultsController<StatisticCoreData> = {
        let fetchRequest: NSFetchRequest<StatisticCoreData> = StatisticCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "statisticId", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()

    // MARK: - Init
    init(
        dataStore: DataStoreProtocol,
        delegate: StatisticStoreDelegate? = nil
    ) throws {
        guard
            let context = dataStore.managedObjectContext
        else {
            throw StatisticStoreError.failedToInitializeContext
        }

        self.delegate = delegate
        self.dataStore = dataStore
        self.context = context
    }

    // MARK: - Helpers
    private func findStatistic(by id: Int) throws -> StatisticCoreData? {
        let fetchRequest: NSFetchRequest<StatisticCoreData> = StatisticCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "statisticId == %d", id)

        do {
            let statistic = try context.fetch(fetchRequest).first
            return statistic
        } catch {
            throw error
        }
    }

    /// Fetches grouped RecordCoreData entries by date.
    private func fetchGroupedRecords() throws -> [NSDictionary] {
        let request = NSFetchRequest<NSDictionary>(entityName: "RecordCoreData")

        let dateExpression = NSExpressionDescription()
        dateExpression.name = "date"
        dateExpression.expression = NSExpression(forKeyPath: "date")
        dateExpression.expressionResultType = .dateAttributeType

        let countExpression = NSExpressionDescription()
        countExpression.name = "trackerCount"
        countExpression.expression = NSExpression(
            forFunction: "count:",
            arguments: [NSExpression(forKeyPath: "trackerId")]
        )
        countExpression.expressionResultType = .integer64AttributeType

        request.propertiesToFetch = [dateExpression, countExpression]
        request.propertiesToGroupBy = [dateExpression]
        request.resultType = .dictionaryResultType

        return try context.fetch(request)
    }

    /// Fetches all trackers from Core Data.
    private func fetchAllTrackers() throws -> [TrackerCoreData] {
        let trackerFetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        return try context.fetch(trackerFetchRequest)
    }

    /// Determines which trackers are active on a given date.
    private func getActiveTrackers(
        for date: Date,
        allTrackers: [TrackerCoreData],
        calendar: Calendar
    ) -> [TrackerCoreData] {
        allTrackers.filter { tracker in
            if let trackerDate = tracker.date {
                return calendar.isDate(trackerDate, inSameDayAs: date)
            } else if let schedule = tracker.schedule as? Set<ScheduleCoreData> {
                let weekday = calendar.component(.weekday, from: date)
                return schedule.contains { $0.weekDay.rawValue == weekday }
            }
            return false
        }
    }

    /// Updates statistics based on completed trackers data.
    private func updateStatistics(with completedDates: [Date], totalCompletedTrackers: Int, recordCount: Int) throws {
        do {
            guard
                let bestPeriodStatistic = try findStatistic(by: 1),
                let perfectDaysStatistic = try findStatistic(by: 2),
                let completedTrackersStatistic = try findStatistic(by: 3),
                let averageTrackersStatistic = try findStatistic(by: 4)
            else {
                throw StatisticStoreError.failedToFindStatistic
            }

            bestPeriodStatistic.value = Int64(bestPeriod(dates: completedDates))
            perfectDaysStatistic.value = Int64(completedDates.count)
            completedTrackersStatistic.value = Int64(totalCompletedTrackers)
            averageTrackersStatistic.value = recordCount == 0 ? 0 : Int64(totalCompletedTrackers) / Int64(recordCount)

            try dataStore.saveContext()
        } catch {
            throw error
        }
    }

    /// Finds the longest period of fully completed days.
    private func bestPeriod(dates: [Date]) -> Int {
        guard !dates.isEmpty else { return 0 }

        let calendar = Calendar.current
        var maxPeriod = 1
        var currentPeriod = 1

        for date in 1..<dates.count {
            let prevDate = dates[date - 1]
            let currentDate = dates[date]

            if let daysBetween = calendar.dateComponents([.day], from: prevDate, to: currentDate).day,
               daysBetween == 1 {
                currentPeriod += 1
            } else {
                maxPeriod = max(maxPeriod, currentPeriod)
                currentPeriod = 1
            }
        }

        return max(maxPeriod, currentPeriod)
    }
}

// MARK: - StatisticStoreProtocol
extension StatisticStore: StatisticStoreProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func fetchStatisticUI(at indexPath: IndexPath) -> StatisticUI {
        let statistic = fetchedResultsController.object(at: indexPath)
        return StatisticUI(from: statistic)
    }

    func fetchNumberOfRecords() throws -> Int {
        let fetchRequest: NSFetchRequest<RecordCoreData> = RecordCoreData.fetchRequest()

        do {
            return try context.fetch(fetchRequest).count
        } catch {
            throw error
        }
    }

    func setupStatisticStore() throws {
        do {
            let statisticsUI: [StatisticUI] = [
                StatisticUI(statisticId: 1,
                            title: NSLocalizedString("statisticBestPeriod", comment: ""),
                            value: 0),
                StatisticUI(statisticId: 2,
                            title: NSLocalizedString("statisticPerfectDays", comment: ""),
                            value: 0),
                StatisticUI(statisticId: 3,
                            title: NSLocalizedString("statisticCompletedTrackers", comment: ""),
                            value: 0),
                StatisticUI(statisticId: 4,
                            title: NSLocalizedString("statisticAverageTrackers", comment: ""),
                            value: 0)
            ]

            for statisticUI in statisticsUI {
                let statistic: StatisticCoreData

                if (try findStatistic(by: statisticUI.statisticId)) != nil {
                    throw StatisticStoreError.statisticAlreadyExists
                } else {
                    statistic = StatisticCoreData(context: context)
                }

                statistic.update(from: statisticUI, in: context)
            }

            try dataStore.saveContext()
        } catch {
            throw error
        }
    }

    func calculateStatistics() throws {
        do {
            let results = try fetchGroupedRecords()
            let allTrackers = try fetchAllTrackers()

            let calendar = Calendar.current
            var completedDates: [Date] = []
            var totalCompletedTrackers = 0

            for dict in results {
                if let count = dict["trackerCount"] as? Int64, let date = dict["date"] as? Date {
                    totalCompletedTrackers += Int(count)

                    let activeTrackers = getActiveTrackers(for: date, allTrackers: allTrackers, calendar: calendar)

                    if count == Int64(activeTrackers.count) {
                        completedDates.append(date)
                    }
                }
            }
            completedDates.sort()

            try updateStatistics(
                with: completedDates,
                totalCompletedTrackers: totalCompletedTrackers,
                recordCount: results.count
            )
        } catch {
            throw error
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension StatisticStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        inProgressChanges.removeAll()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(inProgressChanges)
        inProgressChanges.removeAll()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {

        switch type {
        case .update:
            if let indexPath {
                inProgressChanges.append(.updated(at: indexPath))
            }
        default:
            break
        }
    }
}
