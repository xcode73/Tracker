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
    var numberOfSections: Int? { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func trackerObject(at indexPath: IndexPath) -> TrackerUI?
    func addTracker(_ tracker: TrackerUI) throws
    func updateTracker(tracker: TrackerUI, at indexPath: IndexPath) throws
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

    private lazy var fetchedResultsController: NSFetchedResultsController<Tracker> = {
        guard let truncatedDate = date.truncated else { return NSFetchedResultsController() }

        let weekday = WeekDay(date: date)
        let fetchRequest = NSFetchRequest<Tracker>(entityName: "Tracker")

        if let searchText {
            fetchRequest.predicate = NSPredicate(
                format: "%K == %@ AND %K CONTAINS[cd] %@ OR ANY %K.%K == %lld AND %K CONTAINS[cd] %@",
                #keyPath(Tracker.date), truncatedDate as NSDate,
                #keyPath(Tracker.title), searchText,
                #keyPath(Tracker.schedule), #keyPath(ScheduleCoreData.weekDay), weekday.rawValue,
                #keyPath(Tracker.title), searchText
            )
        } else {
            switch selectedFilter {
            case .completed:
                fetchRequest.predicate = NSPredicate(
                    format: "ANY %K.%K == %@",
                    #keyPath(Tracker.records), #keyPath(Record.date), truncatedDate as NSDate
                )
            case .notCompleted:
                let specialPredicate = NSCompoundPredicate(
                    type: .and,
                    subpredicates: [
                        NSPredicate(format: "%K == %@",
                                    #keyPath(Tracker.date),
                                    truncatedDate as NSDate),
                        NSPredicate(format: "ANY %K == NIL",
                                    #keyPath(Tracker.records))
                    ]
                )

                let regularPredicate = NSCompoundPredicate(
                    type: .and,
                    subpredicates: [
                        NSPredicate(format: "ANY %K.%K == %lld",
                                    #keyPath(Tracker.schedule),
                                    #keyPath(ScheduleCoreData.weekDay),
                                    weekday.rawValue),
                        NSPredicate(format: "SUBQUERY(%K, $record, $record.%K == %@).@count == 0",
                                    #keyPath(Tracker.records),
                                    #keyPath(Record.date),
                                    truncatedDate as NSDate)
                    ]
                )

                let predicate = NSCompoundPredicate(type: .or, subpredicates: [specialPredicate, regularPredicate])

                fetchRequest.predicate = predicate
            default:
                fetchRequest.predicate = NSPredicate(
                    format: "%K == %@ OR ANY %K.%K == %lld",
                    #keyPath(Tracker.date), truncatedDate as NSDate,
                    #keyPath(Tracker.schedule), #keyPath(ScheduleCoreData.weekDay), weekday.rawValue
                )
            }
        }

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Tracker.category.title, ascending: true),
            NSSortDescriptor(keyPath: \Tracker.title, ascending: true)
        ]

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(Tracker.category.title),
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
    var numberOfSections: Int? {
        fetchedResultsController.sections?.count
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func performFetch() throws {
        try fetchedResultsController.performFetch()
    }

    func trackerObject(at indexPath: IndexPath) -> TrackerUI? {
        let storedTracker = fetchedResultsController.object(at: indexPath)

        return TrackerUI(id: storedTracker.trackerId,
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

    func addTracker(_ tracker: TrackerUI) throws {
        let request = NSFetchRequest<Category>(entityName: "Category")
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(Category.title),
                                        tracker.categoryTitle)

        guard let storedCategory = try? context.fetch(request).first else { return }

        try? dataStore.addTracker(tracker: tracker, category: storedCategory)
    }

    func updateTracker(tracker: TrackerUI, at indexPath: IndexPath) throws {
        let categoryRequest = NSFetchRequest<Category>(entityName: "Category")
        categoryRequest.predicate = NSPredicate(format: "%K == %@",
                                                #keyPath(Category.title),
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
