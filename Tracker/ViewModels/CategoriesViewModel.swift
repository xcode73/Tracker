//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 15.01.2025.
//

import Foundation

final class CategoriesViewModel {
    var onChange: Binding<[CategoryStoreUpdate]>?
    var onErrorStateChange: Binding<String?>?

    private var categoryStore: CategoryStoreProtocol

    init(categoryStore: CategoryStoreProtocol) {
        self.categoryStore = categoryStore
        self.categoryStore.delegate = self
    }

    func numberOfRowsInSection(section: Int) -> Int? {
        categoryStore.numberOfRowsInSection(section)
    }

    func getCategory(at indexPath: IndexPath) -> CategoryUI? {
        categoryStore.fetchCategory(at: indexPath)
    }

    func saveCategory(from categoryUI: CategoryUI) throws {
        do {
            try categoryStore.saveCategory(from: categoryUI)
        } catch {
            throw error
        }
    }

    func deleteCategory(at indexPath: IndexPath) {
        try? categoryStore.deleteCategory(at: indexPath)
    }
}

// MARK: - CategoryStoreDelegate
extension CategoriesViewModel: CategoryStoreDelegate {
    func didUpdate(_ updates: [CategoryStoreUpdate]) {
        onChange?(updates)
    }
}
