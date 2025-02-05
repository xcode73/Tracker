//
//  StatisticStore.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 05.02.2025.
//

import CoreData

protocol StatisticStoreProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func setupStatisticsIfNeeded() throws
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

    var userFriendlyMessage: String {
        switch self {
        case .failedToInitializeContext:
            return "Не удалось получить данные. Попробуйте еще раз."
        case .failedToFindStatistic:
            return "Не удалось получить данные. Попробуйте переустановить приложение."
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

    private lazy var fetchedResultsController: NSFetchedResultsController<Statistic> = {
        let fetchRequest: NSFetchRequest<Statistic> = Statistic.fetchRequest()
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

    func setupStatisticsIfNeeded() throws {
        let statistics: Int

        do {
            statistics = try context.count(for: Statistic.fetchRequest())
        } catch {
            throw error
        }

        if statistics == 0 {
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
                    let statistic = Statistic(context: context)

                    statistic.update(from: statisticUI, in: context)
                }

                try dataStore.saveContext()
            } catch {
                throw error
            }
        }
    }

    private func findStatistic(by id: Int) throws -> Statistic {
        let fetchRequest: NSFetchRequest<Statistic> = Statistic.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "statisticId == %d", id)

        do {
            guard let statistic = try context.fetch(fetchRequest).first else {
                throw StatisticStoreError.failedToFindStatistic
            }
            return statistic
        } catch {
            throw error
        }
    }

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
        let fetchRequest: NSFetchRequest<Record> = Record.fetchRequest()

        do {
            return try context.fetch(fetchRequest).count
        } catch {
            throw error
        }
    }

    func calculateStatistics() throws {
        let request = NSFetchRequest<NSDictionary>(entityName: "Record")

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

        do {
            let results = try context.fetch(request)
            let trackerFetchRequest: NSFetchRequest<Tracker> = Tracker.fetchRequest()
            let allTrackers = try context.fetch(trackerFetchRequest)

            let calendar = Calendar.current
                    let today = calendar.component(.weekday, from: Date())
            let activeTrackers = allTrackers.filter { tracker in
                if let schedule = tracker.schedule as? Set<Schedule> {
                    return schedule.contains { $0.weekDay.rawValue == today }
                }
                return tracker.date != nil
            }
            let totalTrackers = activeTrackers.count

            var completedDates: [Date] = []
            var totalCompletedTrackers = 0

            for dict in results {
                if let count = dict["trackerCount"] as? Int64, let date = dict["date"] as? Date {
                    totalCompletedTrackers += Int(count)
                    if count == Int64(totalTrackers) {
                        completedDates.append(date)
                    }
                }
            }
            completedDates.sort()

            let bestPeriodStatistic = try findStatistic(by: 1)
            let perfectDaysStatistic = try findStatistic(by: 2)
            let completedTrackersStatistic = try findStatistic(by: 3)
            let averageTrackersStatistic = try findStatistic(by: 4)

            bestPeriodStatistic.value = Int64(bestPeriod(dates: completedDates))
            perfectDaysStatistic.value = Int64(completedDates.count)
            completedTrackersStatistic.value = Int64(totalCompletedTrackers)
            averageTrackersStatistic.value = results.isEmpty ? 0 : Int64(totalCompletedTrackers) / Int64(results.count)

            try dataStore.saveContext()
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
