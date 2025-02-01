//
//  CategoryStore.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.11.2024.
//

import CoreData

enum CategoryStoreUpdate: Hashable {
    case inserted(at: IndexPath)
    case deleted(from: IndexPath)
    case updated(at: IndexPath)
    case moved(from: IndexPath, to: IndexPath)
}

protocol CategoryStoreDelegate: AnyObject {
    func didUpdate(_ update: [CategoryStoreUpdate])
}

protocol CategoryStoreProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func fetchCategory(at indexPath: IndexPath) -> CategoryUI
    func saveCategory(from categoryUI: CategoryUI) throws
    func deleteCategory(at indexPath: IndexPath) throws
}

final class CategoryStore: NSObject {
    enum CategoriesDataProviderError: Error {
        case failedToInitializeContext
    }

    weak var delegate: CategoryStoreDelegate?
    var inProgressChanges: [CategoryStoreUpdate] = []

    private let context: NSManagedObjectContext
    private let dataStore: DataStoreProtocol

    private lazy var fetchedResultsController: NSFetchedResultsController<Category> = {
        let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Category.title, ascending: true)
        ]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()

    init(_ dataStore: DataStoreProtocol, delegate: CategoryStoreDelegate? = nil) throws {
        guard let context = dataStore.managedObjectContext else {
            throw CategoriesDataProviderError.failedToInitializeContext
        }
        self.delegate = delegate
        self.context = context
        self.dataStore = dataStore
    }

    private func findCategory(by id: UUID) throws -> Category? {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = PredicateFactory.CategoryPredicate.byId(id)

        return try context.fetch(fetchRequest).first
    }
}

// MARK: - CategoryStoreProtocol
extension CategoryStore: CategoryStoreProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func fetchCategory(at indexPath: IndexPath) -> CategoryUI {
        let category = fetchedResultsController.object(at: indexPath)
        return CategoryUI(from: category)
    }

    func saveCategory(from categoryUI: CategoryUI) throws {
        do {
            let category: Category

            if let existingCategory = try findCategory(by: categoryUI.id) {
                category = existingCategory // Обновляем
            } else {
                category = Category(context: context) // Создаем
            }

            category.update(from: categoryUI, in: context)

            try dataStore.saveContext()
        } catch {
        }
    }

    func deleteCategory(at indexPath: IndexPath) throws {
        let category = fetchedResultsController.object(at: indexPath)
        try? dataStore.deleteItem(category)
        try? dataStore.saveContext()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension CategoryStore: NSFetchedResultsControllerDelegate {
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
                inProgressChanges.append(.inserted(at: newIndexPath))
            }
        case .delete:
            if let indexPath {
                inProgressChanges.append(.deleted(from: indexPath))
            }
        case .move:
            if let indexPath, let newIndexPath {
                inProgressChanges.append(.moved(from: indexPath, to: newIndexPath))
            }
        case .update:
            if let indexPath {
                inProgressChanges.append(.updated(at: indexPath))
            }
        default:
            break
        }
    }
}
