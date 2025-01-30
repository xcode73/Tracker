//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 15.01.2025.
//

import Foundation

final class CategoriesViewModel {
    var onChange: Binding<[TrackerCategoryStoreUpdate]>?
    var onErrorStateChange: Binding<String?>?

    private let trackerDataStore: TrackerDataStore

    private lazy var trackerCategoryStore: TrackerCategoryStoreProtocol? = {
        do {
            try trackerCategoryStore = TrackerCategoryStore(
                trackerDataStore,
                delegate: self
            )
            return trackerCategoryStore
        } catch {
            onErrorStateChange?("Данные недоступны.")
            return nil
        }
    }()

    init(trackerDataStore: TrackerDataStore) {
        self.trackerDataStore = trackerDataStore
    }

    func numberOfRowsInSection(section: Int) -> Int? {
        trackerCategoryStore?.numberOfRowsInSection(section)
    }

    func getCategoryTitle(at indexPath: IndexPath) -> String? {
        trackerCategoryStore?.categoryTitle(at: indexPath)
    }

    func addCategory(category: CategoryUI) {
        try? trackerCategoryStore?.addCategory(category: category)
    }

    func updateCategory(categoryTitle: String, at indexPath: IndexPath) {
        try? trackerCategoryStore?.updateCategory(categoryTitle: categoryTitle, at: indexPath)
    }

    func deleteCategory(at indexPath: IndexPath) {
        try? trackerCategoryStore?.deleteCategory(at: indexPath)
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdate(_ updates: [TrackerCategoryStoreUpdate]) {
        onChange?(updates)
    }
}
