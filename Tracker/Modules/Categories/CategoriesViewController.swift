//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 16.10.2024.
//

import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func didSelectCategory(selectedCategory: TrackerCategory, categories: [TrackerCategory])
    func updateCategories(categories: [TrackerCategory])
}

final class CategoriesViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: CategoriesViewControllerDelegate?
    private var categories: [TrackerCategory]?
    private var selectedCategory: TrackerCategory?
    
    private enum LocalConst {
        static let vcTitle = "Категории"
        static let placeholderTitle = "Привычки и события можно \n объединить по смыслу"
        static let createButtonTitle = "Добавить категорию"
        static let deleteCategoryAlertMessage = "Эта категория точно не нужна?"
        static let deleteCategoryAlertIdentifier = "Delete Category Alert"
    }
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        view.separatorStyle = .singleLine
        view.separatorColor = .ypBlack
        view.separatorInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        view.estimatedRowHeight = 75
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
        view.font = Constants.Fonts.ypMedium12
        view.textAlignment = .center
        view.textColor = .ypBlack
        view.text = LocalConst.placeholderTitle
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var createCategoryButton: UIButton = {
        let view = UIButton()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = .ypBlack
        view.titleLabel?.font = Constants.Fonts.ypMedium16
        view.setTitleColor(.white, for: .normal)
        view.addTarget(self, action: #selector(showCategoryViewController), for: .touchUpInside)
        view.setTitle(LocalConst.createButtonTitle, for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // MARK: - Init
    init(
        categories: [TrackerCategory]?,
        selectedCategory: TrackerCategory?
    ) {
        self.categories = categories
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
        changePlaceholderState()
    }
    
    private func setupUI() {
        title = LocalConst.vcTitle
        view.backgroundColor = .ypWhite
        addCreateCategoryButton()
        addTableView()
        addPlaceholderView()
    }
    
    // MARK: - Placeholder
    private func changePlaceholderState() {
        if categories == nil {
            placeholderStackView.isHidden = false
        } else {
            placeholderStackView.isHidden = true
        }
        if let categories, categories.isEmpty {
            placeholderStackView.isHidden = false
        }
    }
    
    // MARK: - Context Menu
    private func showCategoryDetail(indexPath: IndexPath) {
        let vc = CategoryViewController(
            categoryTitle: categories?[indexPath.row].title,
            indexPath: indexPath
        )
        vc.delegate = self
        let navigationController = UINavigationController(
            rootViewController: vc
        )
        navigationController.modalPresentationStyle = .pageSheet
        
        present(navigationController, animated: true)
    }
    
    // MARK: - Delete
    private func deleteCategory(at indexPath: IndexPath) {
        categories?.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        if let categories {
            delegate?.updateCategories(categories: categories)
        }
        changePlaceholderState()
    }
    
    // MARK: - Delete Alert
    func showDeleteCategoryAlert(for indexPath: IndexPath) {
        let model = AlertModel(
            title: nil,
            message: LocalConst.deleteCategoryAlertMessage,
            buttons: [.deleteButton, .cancelButton],
            identifier: LocalConst.deleteCategoryAlertIdentifier,
            completion: { [weak self] in
                guard let self else { return }
                
                self.deleteCategory(at: indexPath)
            }
        )
        
        AlertPresenter.showAlert(on: self, model: model)
    }
    
    // MARK: - Actions
    @objc
    private func showCategoryViewController() {
        let vc = CategoryViewController(categoryTitle: nil, indexPath: nil)
        vc.delegate = self
        let navigationController = UINavigationController(
            rootViewController: vc
        )
        navigationController.modalPresentationStyle = .pageSheet
        
        present(navigationController, animated: true)
    }
    
    // MARK: - Constraints
    private func addCreateCategoryButton() {
        view.addSubview(createCategoryButton)
        
        NSLayoutConstraint.activate([
            createCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            createCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func addTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.bottomAnchor.constraint(equalTo: createCategoryButton.topAnchor, constant: -16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
        guard let categories else {
            changePlaceholderState()
            return 0
        }
        
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell,
            let categories
        else {
            return UITableViewCell()
        }
        
        let cellPosition: CellPosition
        
        switch indexPath.row {
        case 0:
            if categories.count == 1 {
                cellPosition = .single
                cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
            } else {
                cellPosition = .first
                cell.separatorInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
            }
        case categories.count - 1:
            cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
            cellPosition = .last
        default:
            cellPosition = .regular
            cell.separatorInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        }
        
        cell.configure(
            with: categories[indexPath.row],
            cellPosition: cellPosition
        )
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let categories, let selectedCategory else { return }
        
        if selectedCategory.title == categories[indexPath.row].title {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let categories else { return }
        
        delegate?.didSelectCategory(selectedCategory: categories[indexPath.row], categories: categories)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying,
                                          previewProvider: nil,
                                          actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: Constants.ButtonTitles.edit)
                { [weak self] _ in
                    self?.showCategoryDetail(indexPath: indexPath)
                },
                
                UIAction(title: Constants.ButtonTitles.delete, attributes: .destructive)
                { [weak self] _ in
                    self?.showDeleteCategoryAlert(for: indexPath)
                },
            ])
        })
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryCell else { return nil }
        
        let selectedView = cell.configureSelectedView()
        return UITargetedPreview(view: selectedView)
    }
}

// MARK: - CategoryViewControllerDelegate
extension CategoriesViewController: CategoryViewControllerDelegate {
    func createCategory(categoryTitle: String, indexPath: IndexPath?) {
        dismiss(animated: true)
        
        if let indexPath {
            // change category title
            let newCategories = categories?.map { category in
                if category.title == categories?[indexPath.row].title {
                    return TrackerCategory(title: categoryTitle, trackers: category.trackers)
                }
                return category
            }
            categories = newCategories
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [])
            self.categories?.append(newCategory)
            tableView.reloadData()
        }
        
        changePlaceholderState()
        
        guard let categories else { return }
        delegate?.updateCategories(categories: categories)
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("Categories") {
    let selectedCategory = TrackerCategory(title: "Quux", trackers: [])
    let categories: [TrackerCategory] = [
        selectedCategory,
        TrackerCategory(title: "Foo", trackers: []),
        TrackerCategory(title: "Baz", trackers: []),
        TrackerCategory(title: "Bar", trackers: []),
    ]
    let navigationController = UINavigationController(
        rootViewController: CategoriesViewController(categories: categories, selectedCategory: selectedCategory)
    )
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}

@available(iOS 17, *)
#Preview("Empty") {
    let selectedCategory: TrackerCategory? = nil
    let categories: [TrackerCategory]? = nil
    let navigationController = UINavigationController(
        rootViewController: CategoriesViewController(categories: categories, selectedCategory: selectedCategory)
    )
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}
#endif

