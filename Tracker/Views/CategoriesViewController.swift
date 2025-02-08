//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 16.10.2024.
//

import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func didSelectCategory(_ categoryUI: CategoryUI)
}

final class CategoriesViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: CategoriesViewControllerDelegate?

    private var viewModel: CategoriesViewModel?
    private var selectedCategory: CategoryUI?

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

    private lazy var placeholderStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .center
        view.spacing = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var placeholderImageView: UIImageView = {
        let view = UIImageView()
        view.image = .icDizzy
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var placeholderLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.font = Fonts.ypMedium12
        view.textAlignment = .center
        view.textColor = .ypBlack
        view.text = NSLocalizedString("placeholderCategories", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var createCategoryButton: UIButton = {
        let view = UIButton()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = .ypBlack
        view.titleLabel?.font = Fonts.ypMedium16
        view.setTitleColor(.ypWhite, for: .normal)
        view.addTarget(self, action: #selector(showCategoryViewController), for: .touchUpInside)
        view.setTitle(NSLocalizedString("buttonAddCategory", comment: ""), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init
    init(
        selectedCategory: CategoryUI?
    ) {
        self.selectedCategory = selectedCategory

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupLayout()
    }

    func initialize(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        bind()
    }

    private func bind() {
        guard let viewModel = viewModel else { return }

        viewModel.onChange = { [weak self] updates in
            self?.update(updates)
        }

        viewModel.onErrorStateChange = { [weak self] _ in
            self?.showStoreErrorAlert("")
        }
    }

    private func update(_ updates: [CategoryStoreUpdate]) {
        var movedToIndexPaths = [IndexPath]()
        var lastIndexPaths = [IndexPath]()

        tableView.performBatchUpdates({
            for update in updates {
                switch update {
                case let .inserted(at: indexPath):
                    tableView.insertRows(at: [indexPath], with: .automatic)
                case let .deleted(from: indexPath):
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                case let .updated(at: indexPath):
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                case let .moved(from: source, to: target):
                    tableView.moveRow(at: source, to: target)
                    movedToIndexPaths.append(target)
                    lastIndexPaths.append(source)
                }

            }
        }, completion: { [weak self] _ in
            guard let self else { return }

            self.tableView.reloadRows(at: movedToIndexPaths, with: .automatic)
            self.tableView.reloadRows(at: lastIndexPaths, with: .automatic)
        })
    }

    private func setupUI() {
        title = NSLocalizedString("vcTitleCategories", comment: "")
        view.backgroundColor = .ypWhite
    }

    // MARK: - Context Menu
    private func showCategoryDetail(indexPath: IndexPath) {
        let viewController = CategoryViewController(
            categoryUI: viewModel?.getCategory(at: indexPath)
        )
        viewController.delegate = self
        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        navigationController.modalPresentationStyle = .pageSheet

        present(navigationController, animated: true)
    }

    // MARK: - Delete Category
    private func deleteCategory(at indexPath: IndexPath) {
        viewModel?.deleteCategory(at: indexPath)
    }

    // MARK: - Alerts
    func showDeleteCategoryAlert(for indexPath: IndexPath) {
        let model = AlertModel(
            title: nil,
            message: NSLocalizedString("alertMessageDeleteCategory", comment: ""),
            buttons: [.deleteButton, .cancelButton],
            identifier: "Delete Category Alert",
            completion: { [weak self] in
                guard let self else { return }

                self.deleteCategory(at: indexPath)
            }
        )

        AlertPresenter.showAlert(on: self, model: model)
    }

    func showStoreErrorAlert(_ message: String) {
        let model = AlertModel(
            title: NSLocalizedString("alertTitleStoreError", comment: ""),
            message: message,
            buttons: [.cancelButton],
            identifier: "Category Store Error Alert",
            completion: nil
        )

        AlertPresenter.showAlert(on: self, model: model)
    }

    // MARK: - Actions
    @objc
    private func showCategoryViewController() {
        let viewController = CategoryViewController()
        viewController.delegate = self
        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        navigationController.modalPresentationStyle = .pageSheet

        present(navigationController, animated: true)
    }

    // MARK: - Constraints
    private func setupLayout() {
        addCreateCategoryButton()
        addTableView()
        addPlaceholderView()
    }

    private func addCreateCategoryButton() {
        view.addSubview(createCategoryButton)

        NSLayoutConstraint.activate([
            createCategoryButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20
            ),
            createCategoryButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20
            ),
            createCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func addTableView() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: createCategoryButton.topAnchor, constant: -16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
    }

    private func addPlaceholderView() {
        view.addSubview(placeholderStackView)
        placeholderStackView.addArrangedSubview(placeholderImageView)
        placeholderStackView.addArrangedSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            placeholderStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
}

// MARK: - UITableViewDataSource
extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let categoriesCount = viewModel?.numberOfRowsInSection(section: section)

        if categoriesCount == nil || categoriesCount == 0 {
            placeholderStackView.isHidden = false
        } else {
            placeholderStackView.isHidden = true
        }

        return categoriesCount ?? 0
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseIdentifier,
                                                     for: indexPath) as? CategoryTableViewCell,
            let categoryUI = viewModel?.getCategory(at: indexPath)
        else {
            return UITableViewCell()
        }

        cell.configure(with: categoryUI)

        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        guard
            let category = viewModel?.getCategory(at: indexPath),
            let selectedCategory
        else {
            return
        }

        if selectedCategory.id == category.id {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        guard let categoryUI = viewModel?.getCategory(at: indexPath) else { return }

        delegate?.didSelectCategory(categoryUI)
    }

    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {

        return UIContextMenuConfiguration(identifier: indexPath as NSCopying,
                                          previewProvider: nil,
                                          actionProvider: { _ in
            return UIMenu(children: [
                UIAction(title: NSLocalizedString("buttonEdit", comment: "")) { [weak self] _ in
                    self?.showCategoryDetail(indexPath: indexPath)
                },
                UIAction(title: NSLocalizedString("buttonDelete", comment: ""),
                         attributes: .destructive) { [weak self] _ in
                             self?.showDeleteCategoryAlert(for: indexPath)
                         }
            ])
        })
    }

    func tableView(
        _ tableView: UITableView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let cell = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell
        else {
            return nil
        }

        let selectedView = cell.configureSelectedView()
        return UITargetedPreview(view: selectedView)
    }
}

// MARK: - CategoryViewControllerDelegate
extension CategoriesViewController: CategoryViewControllerDelegate {
    func saveCategory(_ categoryUI: CategoryUI) {
        dismiss(animated: true)

        do {
            try viewModel?.saveCategory(from: categoryUI)
        } catch {
            showStoreErrorAlert(error.localizedDescription)
        }
    }
}
