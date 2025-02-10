//
//  FiltersViewModel.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 25.01.2025.
//

import Foundation

final class FiltersViewModel {
    private let filters = Filter.allCases
    var selectedFilter: Filter?

    init(selectedFilter: Filter?) {
        self.selectedFilter = selectedFilter
    }

    func numberOfRows() -> Int {
        filters.count
    }

    func getFilter(at indexPath: IndexPath) -> Filter {
        filters[indexPath.row]
    }
}
