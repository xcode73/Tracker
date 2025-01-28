//
//  TrackerStore.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.11.2024.
//

import CoreData

enum TrackerStoreUpdate: Hashable {
    enum SectionUpdate: Hashable {
        case inserted(Int)
        case deleted(Int)
    }

  enum ObjectUpdate: Hashable {
    case inserted(at: IndexPath)
    case deleted(from: IndexPath)
    case updated(at: IndexPath)
    case moved(from: IndexPath, to: IndexPath)
  }

  case section(SectionUpdate)
  case object(ObjectUpdate)
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: [TrackerStoreUpdate])
}

protocol TrackerStoreProtocol {
    var numberOfSections: Int { get }
    func setDate(_ date: Date)
    func numberOfItemsInSection(_ section: Int) -> Int
    func trackerObject(at indexPath: IndexPath) -> Tracker?
    func addTracker(_ tracker: Tracker) throws
    func updateTracker(tracker: Tracker, at indexPath: IndexPath) throws
    func deleteTracker(at indexPath: IndexPath) throws
    func sectionTitle(at section: Int) -> String?
    func categoryTitle(at indexPath: IndexPath) -> String?
    func refresh() throws
    func performFetch() throws
}

final class TrackerStore: NSObject {
    enum TrackerDataProviderError: Error {
        case failedToInitializeContext
    }

    weak var delegate: TrackerStoreDelegate?
    private var inProgressChanges: [TrackerStoreUpdate] = []

    private let context: NSManagedObjectContext
    private let dataStore: TrackerDataStore
    private var date: Date
    private var searchText: String?
    private var selectedFilter: Filter

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        guard let truncatedDate = date.truncated else { return NSFetchedResultsController() }

        let weekday = WeekDay(date: date)
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")

        if let searchText {
            fetchRequest.predicate = NSPredicate(
                format: "%K == %@ AND %K CONTAINS[cd] %@ OR ANY %K.%K == %lld AND %K CONTAINS[cd] %@",
                #keyPath(TrackerCoreData.date), truncatedDate as NSDate,
                #keyPath(TrackerCoreData.title), searchText,
                #keyPath(TrackerCoreData.schedule), #keyPath(ScheduleCoreData.weekDay), weekday.rawValue,
                #keyPath(TrackerCoreData.title), searchText
            )
        } else {
            switch selectedFilter {
            case .completed:
                fetchRequest.predicate = NSPredicate(
                    format: "ANY %K.%K == %@",
                    #keyPath(TrackerCoreData.records), #keyPath(TrackerRecordCoreData.date), truncatedDate as NSDate
                )
            case .notCompleted:
//                let compound1 = NSCompoundPredicate(
//                    type: .and,
//                    subpredicates: [
//                        NSPredicate(format: "%K == %@",
//                                    #keyPath(TrackerCoreData.date),
//                                    truncatedDate as NSDate),
//                        NSPredicate(format: "ANY %K == NIL",
//                                    #keyPath(TrackerCoreData.records))
//                    ]
//                )
//
//                let compound2 = NSCompoundPredicate(
//                    type: .and,
//                    subpredicates: [
//                        NSPredicate(format: "ANY %K.%K == %lld",
//                                    #keyPath(TrackerCoreData.schedule),
//                                    #keyPath(ScheduleCoreData.weekDay),
//                                    weekday.rawValue)
//                        NSPredicate(format: "NONE %K.%K == %@",
//                                    #keyPath(TrackerCoreData.records),
//                                    #keyPath(TrackerRecordCoreData.date),
//                                    truncatedDate as NSDate)
//                    ]
//                )

//                let compound3 = NSCompoundPredicate(type: .or, subpredicates: [compound1, compound2])
//
//                fetchRequest.predicate = compound3

                fetchRequest.predicate = NSPredicate(
                    format: "(%K == %@) AND (ANY %K == NIL) OR (ANY %K.%K == %lld) AND (NONE %K.%K == %@)",
                    #keyPath(TrackerCoreData.date), truncatedDate as NSDate,
                    #keyPath(TrackerCoreData.records),
                    #keyPath(TrackerCoreData.schedule), #keyPath(ScheduleCoreData.weekDay), weekday.rawValue,
                    #keyPath(TrackerCoreData.records), #keyPath(TrackerRecordCoreData.date), truncatedDate as NSDate
                )
            default:
                fetchRequest.predicate = NSPredicate(
                    format: "%K == %@ OR ANY %K.%K == %lld",
                    #keyPath(TrackerCoreData.date), truncatedDate as NSDate,
                    #keyPath(TrackerCoreData.schedule), #keyPath(ScheduleCoreData.weekDay), weekday.rawValue
                )
            }
        }

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category.title, ascending: true),
            NSSortDescriptor(keyPath: \TrackerCoreData.title, ascending: true)
        ]

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.category.title),
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()

    init(
        dataStore: TrackerDataStore,
        delegate: TrackerStoreDelegate,
        date: Date,
        selectedFilter: Filter,
        searchText: String?
    ) throws {
        guard
            let context = dataStore.managedObjectContext
        else {
            throw TrackerDataProviderError.failedToInitializeContext
        }
        self.date = date
        self.delegate = delegate
        self.context = context
        self.dataStore = dataStore
        self.selectedFilter = selectedFilter
        self.searchText = searchText
    }
}

// MARK: - TrackerStoreProtocol
extension TrackerStore: TrackerStoreProtocol {
    func setDate(_ date: Date) {
        self.date = date
    }

    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func performFetch() throws {
        try fetchedResultsController.performFetch()
    }

    func trackerObject(at indexPath: IndexPath) -> Tracker? {
        let storedTracker = fetchedResultsController.object(at: indexPath)

        return Tracker(id: storedTracker.trackerId,
                       categoryTitle: storedTracker.category.title,
                       title: storedTracker.title,
                       color: storedTracker.color,
                       emoji: storedTracker.emoji,
                       schedule: storedTracker.schedule?.allObjects.map { ($0 as AnyObject).weekDay },
                       date: storedTracker.date)
    }

    func categoryTitle(at indexPath: IndexPath) -> String? {
        return fetchedResultsController.object(at: indexPath).category.title
    }

    func sectionTitle(at section: Int) -> String? {
        fetchedResultsController.sections?[section].name
    }

    func addTracker(_ tracker: Tracker) throws {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(TrackerCategoryCoreData.title),
                                        tracker.categoryTitle)

        guard let storedCategory = try? context.fetch(request).first else { return }

        try? dataStore.addTracker(tracker: tracker, category: storedCategory)
    }

    func updateTracker(tracker: Tracker, at indexPath: IndexPath) throws {
        let categoryRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        categoryRequest.predicate = NSPredicate(format: "%K == %@",
                                                #keyPath(TrackerCategoryCoreData.title),
                                                tracker.categoryTitle)
        guard let storedCategory = try? context.fetch(categoryRequest).first else { return }

        let storedTracker = fetchedResultsController.object(at: indexPath)
        storedTracker.trackerId = tracker.id
        storedTracker.title = tracker.title
        storedTracker.color = tracker.color
        storedTracker.emoji = tracker.emoji
        storedTracker.date = tracker.date
        storedTracker.category = storedCategory

        try? dataStore.saveContext()
    }

    func deleteTracker(at indexPath: IndexPath) throws {
        let tracker = fetchedResultsController.object(at: indexPath)
        try? dataStore.deleteItem(tracker)
        try? dataStore.saveContext()
    }

    func refresh() throws {
        try? dataStore.refresh()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
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
        case .insert:
            if let newIndexPath {
                inProgressChanges.append(.object(.inserted(at: newIndexPath)))
            }
        case .delete:
            if let indexPath {
                inProgressChanges.append(.object(.deleted(from: indexPath)))
            }
        case .move:
            if let indexPath, let newIndexPath {
                inProgressChanges.append(.object(.moved(from: indexPath, to: newIndexPath)))
            }
        case .update:
            if let indexPath {
                inProgressChanges.append(.object(.updated(at: indexPath)))
            }
        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        if type == .insert {
            inProgressChanges.append(.section(.inserted(sectionIndex)))
        } else if type == .delete {
            inProgressChanges.append(.section(.deleted(sectionIndex)))
        }
    }
}
