//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 24.01.2025.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(filter: Filter)
}

class FiltersViewController: UIViewController {
    weak var delegate: FiltersViewControllerDelegate?

    private var viewModel: FiltersViewModel?
    private var selectedFilter: Filter?

    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: view.bounds, style: .insetGrouped)
        view.backgroundColor = .ypWhite
        view.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier)
        view.separatorStyle = .singleLine
        view.separatorColor = .ypBlack
        view.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.estimatedRowHeight = 75
        view.rowHeight = 75
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypWhite
        title = NSLocalizedString("vcTitleFilters", comment: "")
        setupViews()
    }

    func initialize(viewModel: FiltersViewModel) {
        self.viewModel = viewModel
    }

    private func setupViews() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                               constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
    }

}

// MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows() ?? 0
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseIdentifier,
                                                     for: indexPath) as? CategoryTableViewCell
        else {
            return UITableViewCell()
        }

        cell.configure(
            with: viewModel?.getFilter(at: indexPath).title ?? ""
        )

        return cell
    }
}

// MARK: - UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        guard
            let filter = viewModel?.getFilter(at: indexPath),
            let selectedFilter = viewModel?.selectedFilter
        else {
            return
        }

        if selectedFilter == filter {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        guard
            let filter = viewModel?.getFilter(at: indexPath)
        else {
            return
        }

        delegate?.didSelectFilter(filter: filter)
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview() {
    let viewController = FiltersViewController()
    let selectedFilter = Filter.all
    let viewModel = FiltersViewModel(selectedFilter: selectedFilter)
    viewController.initialize(viewModel: viewModel)
    let navigationController = UINavigationController( rootViewController: viewController )
    navigationController.modalPresentationStyle = .pageSheet

    return navigationController
}
#endif
