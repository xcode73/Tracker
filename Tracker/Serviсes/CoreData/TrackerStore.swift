//
//  TrackerStore.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.11.2024.
//

import CoreData

protocol TrackerStoreProtocol {
    var delegate: TrackerStoreDelegate? { get set }
    var numberOfSections: Int { get }
    func updateFetchRequest(with filter: Filter, for date: Date) throws
    func updateFetchRequest(with searchText: String?, for date: Date) throws
    func numberOfItemsInSection(_ section: Int) -> Int
    func fetchTracker(at indexPath: IndexPath) -> TrackerUI
    func fetchTrackerWithCategory(at indexPath: IndexPath) -> (CategoryUI, TrackerUI)?
    func saveTracker(from trackerUI: TrackerUI, categoryUI: CategoryUI) throws
    func deleteTracker(_ trackerUI: TrackerUI) throws
    func sectionTitle(at section: Int) -> String?
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: [TrackerStoreUpdate])
}

enum TrackerStoreError: Error {
    case failedToInitializeContext
    case failedToFindTracker
    case failedToFindCategory
    case failedToFindMockCategories

    var userFriendlyMessage: String {
        switch self {
        case .failedToInitializeContext:
            return "Не удалось получить данные. Попробуйте еще раз."
        case .failedToFindTracker:
            return "Трекер не найден"
        case .failedToFindCategory:
            return "Категория не найдена"
        case .failedToFindMockCategories:
            return "❌ Ошибка: Не найдены Mock категории 'Foo' и 'Baz'"
        }
    }
}

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

class TrackerStore: NSObject {
    // MARK: - Properties
    weak var delegate: TrackerStoreDelegate?
    private var inProgressChanges: [TrackerStoreUpdate] = []

    let context: NSManagedObjectContext
    let dataStore: DataStoreProtocol
    private var selectedFilter: Filter = .all

    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>

    // MARK: - Init
    init(
        dataStore: DataStoreProtocol,
        delegate: TrackerStoreDelegate? = nil
    ) throws {
        guard
            let context = dataStore.managedObjectContext
        else {
            throw TrackerStoreError.failedToInitializeContext
        }

        self.delegate = delegate
        self.context = context
        self.dataStore = dataStore
        self.fetchedResultsController = NSFetchedResultsController()
    }

    private func applySortAndRefresh(with fetchRequest: NSFetchRequest<TrackerCoreData>) throws {
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "isPinned", ascending: false),
            NSSortDescriptor(key: "sectionTitle", ascending: false),
            NSSortDescriptor(key: "title", ascending: true)
        ]

        let newFetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "sectionTitle",
            cacheName: nil
        )

        newFetchedResultsController.delegate = self
        fetchedResultsController = newFetchedResultsController

        do {
            try fetchedResultsController.performFetch()
        } catch {
            throw error
        }

        delegate?.didUpdate(inProgressChanges)
    }

    private func findTracker(by id: UUID) -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = PredicateFactory.TrackerPredicate.byId(id)

        return try? context.fetch(fetchRequest).first
    }

    private func findCategory(by id: UUID) throws -> CategoryCoraData {
        let fetchRequest: NSFetchRequest<CategoryCoraData> = CategoryCoraData.fetchRequest()
        fetchRequest.predicate = PredicateFactory.CategoryPredicate.byId(id)

        guard
            let category = try context.fetch(fetchRequest).first
        else {
            throw TrackerStoreError.failedToFindCategory
        }

        return category
    }
}

// MARK: - TrackerStoreProtocol
extension TrackerStore: TrackerStoreProtocol {
    func updateFetchRequest(with filter: Filter, for date: Date) throws {
        let newFetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()

        switch filter {
        case .completed:
            newFetchRequest.predicate = PredicateFactory.TrackerPredicate.completed(on: date)
        case .notCompleted:
            newFetchRequest.predicate = PredicateFactory.TrackerPredicate.notCompleted(date)
        default:
            newFetchRequest.predicate = PredicateFactory.TrackerPredicate.all(date)
        }

        do {
            try applySortAndRefresh(with: newFetchRequest)
        } catch {
            throw error
        }
    }

    func updateFetchRequest(with searchText: String?, for date: Date) throws {
        let newFetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()

        if let searchText {
            newFetchRequest.predicate = PredicateFactory.TrackerPredicate.search(
                date: date,
                searchText: searchText
            )
        } else {
            newFetchRequest.predicate = PredicateFactory.TrackerPredicate.all(date)
        }

        do {
            try applySortAndRefresh(with: newFetchRequest)
        } catch {
            throw error
        }
    }

    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func fetchTracker(at indexPath: IndexPath) -> TrackerUI {
        let tracker = fetchedResultsController.object(at: indexPath)
        return TrackerUI(from: tracker)
    }

    func fetchCategory(at indexPath: IndexPath) -> CategoryUI {
        let category = fetchedResultsController.object(at: indexPath).category
        return CategoryUI(from: category)
    }

    func fetchTrackerWithCategory(at indexPath: IndexPath) -> (CategoryUI, TrackerUI)? {
        let tracker = fetchedResultsController.object(at: indexPath)
        let category = tracker.category
        let categoryUI = CategoryUI(from: category)
        let trackerUI = TrackerUI(from: tracker)

        return (categoryUI, trackerUI)
    }

    func sectionTitle(at section: Int) -> String? {
        fetchedResultsController.sections?[section].name
    }

    func saveTracker(from trackerUI: TrackerUI, categoryUI: CategoryUI) throws {
        do {
            let category = try findCategory(by: categoryUI.id)
            let tracker: TrackerCoreData

            if let existingTracker = findTracker(by: trackerUI.id) {
                tracker = existingTracker
            } else {
                tracker = TrackerCoreData(context: context)
            }

            tracker.update(from: trackerUI, category: category, in: context)

            try dataStore.saveContext()
        } catch {
            throw error
        }
    }

    func deleteTracker(_ trackerUI: TrackerUI) throws {
        guard let tracker = findTracker(by: trackerUI.id) else {
            throw TrackerStoreError.failedToFindTracker
        }

        do {
            try dataStore.deleteItem(tracker)
            try dataStore.saveContext()
        } catch {
            throw error
        }
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
