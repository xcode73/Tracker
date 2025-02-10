//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 17.10.2024.
//

import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func saveCategory(_ categoryUI: CategoryUI)
}

final class CategoryViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: CategoryViewControllerDelegate?
    private var sectionItems = [""]
    private var categoryTitle: String?
    private var categoryUI: CategoryUI?

    private enum LocalConst {
        static let createCategoryViewTitle = NSLocalizedString("vcTitleCategoryAdd", comment: "")
        static let editCategoryViewTitle = NSLocalizedString("vcTitleCategoryEdit", comment: "")
        static let createButtonTitle = NSLocalizedString("buttonDone", comment: "")
        static let titleCellPlaceholder = NSLocalizedString("placeholderCategory", comment: "")
        static let errorCellTitle = NSLocalizedString("errorMessageCharacterLimit", comment: "")
    }

    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(TitleTableViewCell.self, forCellReuseIdentifier: CategoryTitleTableViewCell.reuseIdentifier)
        view.separatorStyle = .none
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var saveCategoryButton: UIButton = {
        let view = UIButton()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.titleLabel?.font = Fonts.ypMedium16
        view.setTitleColor(.ypWhite, for: .normal)
        view.addTarget(self, action: #selector(didTapSaveCategoryButton), for: .touchUpInside)
        view.setTitle(LocalConst.createButtonTitle, for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var tap: UITapGestureRecognizer = {
        let view = UITapGestureRecognizer()
        view.addTarget(self, action: #selector(hideKeyboard))
        return view
    }()

    // MARK: - Init
    init(
        categoryUI: CategoryUI? = nil
    ) {
        super.init(nibName: nil, bundle: nil)

        guard let categoryUI else { return }
        self.categoryUI = categoryUI
        self.categoryTitle = categoryUI.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .ypWhite
        if categoryTitle != nil {
            title = LocalConst.editCategoryViewTitle
        } else {
            title = LocalConst.createCategoryViewTitle
        }

        addSaveCategoryButton()
        addTableView()
        changeCreateCategoryButtonState()
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func changeCreateCategoryButtonState() {
        if categoryTitle == nil {
            saveCategoryButton.isEnabled = false
            saveCategoryButton.backgroundColor = .ypGray
        }

        if let categoryTitle, !categoryTitle.trimmingCharacters(in: .whitespaces).isEmpty {
            saveCategoryButton.isEnabled = true
            saveCategoryButton.backgroundColor = .ypBlack
        } else {
            saveCategoryButton.isEnabled = false
            saveCategoryButton.backgroundColor = .ypGray
        }
    }

    // MARK: - Actions
    @objc
    private func didTapSaveCategoryButton() {
        guard let categoryTitle else { return }

        let updatedCategoryUI: CategoryUI?

        if let categoryUI {
            updatedCategoryUI = CategoryUI(categoryID: categoryUI.id,
                                           title: categoryTitle,
                                           trackers: categoryUI.trackers)
        } else {
            updatedCategoryUI = CategoryUI(categoryID: UUID(), title: categoryTitle)
        }

        guard let updatedCategoryUI else { return }

        delegate?.saveCategory(updatedCategoryUI)
    }

    @objc
    private func hideKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Constraints
    private func addSaveCategoryButton() {
        view.addSubview(saveCategoryButton)

        NSLayoutConstraint.activate([
            saveCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            saveCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                         constant: -20),
            saveCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            saveCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func addTableView() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.bottomAnchor.constraint(equalTo: saveCategoryButton.topAnchor, constant: -16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = CategoryTitleTableViewCell()
            cell.configure(
                with: categoryTitle,
                placeholder: LocalConst.titleCellPlaceholder
            )
            cell.delegate = self
            return cell
        case 1:
            let cell = ErrorTableViewCell()
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - Table view delegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 1:
            return 38
        default:
            return 75
        }
    }
}

// MARK: - CategoryTitleCellDelegate
extension CategoryViewController: CategoryTitleCellDelegate {
    func titleChanged(title: String) {
        let items = sectionItems.count
        categoryTitle = title
        changeCreateCategoryButtonState()

        switch title.count {
        case 0...37:
            if items > 1 {
                sectionItems.removeLast()
                tableView.performBatchUpdates {
                    tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                } completion: { _ in }
            }
            sectionItems = [title]
        case 38:
            sectionItems.append(LocalConst.errorCellTitle)
            tableView.performBatchUpdates {
                tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            } completion: { _ in }
        default:
            break
        }
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("Add Category") {
    let viewController = CategoryViewController()
    let navigationController = UINavigationController(
        rootViewController: viewController
    )
    navigationController.modalPresentationStyle = .pageSheet

    return navigationController
}
#endif
