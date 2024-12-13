//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.11.2024.
//

import CoreData

enum TrackerCategoryStoreUpdate: Hashable {
    case inserted(at: IndexPath)
    case deleted(from: IndexPath)
    case updated(at: IndexPath)
    case moved(from: IndexPath, to: IndexPath)
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(_ update: [TrackerCategoryStoreUpdate])
}

protocol TrackerCategoryStoreProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func categoryTitle(at indexPath: IndexPath) -> (String)?
    func addCategory(category: TrackerCategory) throws
    func updateCategory(categoryTitle: String, at indexPath: IndexPath) throws
    func deleteCategory(at indexPath: IndexPath) throws
}

final class TrackerCategoryStore: NSObject {
    enum CategoriesDataProviderError: Error {
        case failedToInitializeContext
    }
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private let context: NSManagedObjectContext
    private let dataStore: TrackerDataStore

    var inProgressChanges: [TrackerCategoryStoreUpdate] = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)
        ]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(_ dataStore: TrackerDataStore, delegate: TrackerCategoryStoreDelegate) throws {
        guard let context = dataStore.managedObjectContext else {
            throw CategoriesDataProviderError.failedToInitializeContext
        }
        self.delegate = delegate
        self.context = context
        self.dataStore = dataStore
    }
}

// MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func categoryTitle(at indexPath: IndexPath) -> (String)? {
        fetchedResultsController.object(at: indexPath).title
    }
    
    func addCategory(category: TrackerCategory) throws {
        try? dataStore.addCategory(category: category)
    }
    
    func updateCategory(categoryTitle: String, at indexPath: IndexPath) throws {
        let category = fetchedResultsController.object(at: indexPath)
        category.title = categoryTitle
        
        try? dataStore.saveContext()
    }
    
    func deleteCategory(at indexPath: IndexPath) throws {
        let category = fetchedResultsController.object(at: indexPath)
        try? dataStore.deleteItem(category)
        try? dataStore.saveContext()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
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
        
        let itemsCount = fetchedResultsController.fetchedObjects?.count ?? 0
        
        switch type {
        case .insert:
            if let newIndexPath {
                inProgressChanges.append(.inserted(at: newIndexPath))
                if itemsCount > 1 {
                    let updatedIndexPath: IndexPath = IndexPath(item: newIndexPath.item - 1, section: 0)
                    inProgressChanges.append(.updated(at: updatedIndexPath))
                }
            }
        case .delete:
            if let indexPath = indexPath {
                inProgressChanges.append(.deleted(from: indexPath))
                if itemsCount > 1 {
                    let updatedIndexPath: IndexPath = IndexPath(item: indexPath.item - 1, section: 0)
                    inProgressChanges.append(.updated(at: updatedIndexPath))
                }
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
