//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 17.10.2024.
//

import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func createCategory(categoryTitle: String, indexPath: IndexPath?)
}

final class CategoryViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: CategoryViewControllerDelegate?
    private var sectionItems = [""]
    private var categoryTitle: String?
    private var indexPath: IndexPath?
    
    private enum LocalConst {
        static let createCategoryViewTitle = "Новая категория"
        static let editCategoryViewTitle = "Редактирование категории"
        static let createButtonTitle = "Готово"
        static let titleCellPlaceholder = "Введите название категории"
        static let errorCellTitle = "Ограничение 38 символов"
    }
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(TitleCell.self, forCellReuseIdentifier: CategoryTitleCell.reuseIdentifier)
        
        view.separatorStyle = .none
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var createCategoryButton: UIButton = {
        let view = UIButton()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.titleLabel?.font = Constants.Fonts.ypMedium16
        view.setTitleColor(.white, for: .normal)
        view.addTarget(self, action: #selector(didTapCreateCategoryButton), for: .touchUpInside)
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
        categoryTitle: String?,
        indexPath: IndexPath?
    ) {
        self.categoryTitle = categoryTitle
        self.indexPath = indexPath
        
        super.init(nibName: nil, bundle: nil)
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
        
        addCreateCategoryButton()
        addTableView()
        
        changeCreateCategoryButtonState()
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func changeCreateCategoryButtonState() {
        if categoryTitle == nil {
            createCategoryButton.isEnabled = false
            createCategoryButton.backgroundColor = .ypGray
        }
        
        if let categoryTitle, !categoryTitle.trimmingCharacters(in: .whitespaces).isEmpty {
            createCategoryButton.isEnabled = true
            createCategoryButton.backgroundColor = .ypBlack
        } else {
            createCategoryButton.isEnabled = false
            createCategoryButton.backgroundColor = .ypGray
        }
    }
    
    // MARK: - Actions
    @objc
    private func didTapCreateCategoryButton() {
        guard let categoryTitle else { return }
        
        delegate?.createCategory(categoryTitle: categoryTitle, indexPath: indexPath)
    }
    
    @objc
    private func hideKeyboard() {
        view.endEditing(true)
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
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = CategoryTitleCell()
            cell.configure(
                with: categoryTitle,
                placeholder: LocalConst.titleCellPlaceholder
            )
            cell.delegate = self
            return cell
        case 1:
            let cell = ErrorCell()
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
    let navigationController = UINavigationController(
        rootViewController: CategoryViewController(categoryTitle: nil, indexPath: nil)
    )
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}

@available(iOS 17, *)
#Preview("Edit Category") {
    let categoryTitle = "Foo"
    let indexPath = IndexPath(row: 0, section: 0)
    let navigationController = UINavigationController(
        rootViewController: CategoryViewController(categoryTitle: categoryTitle, indexPath: indexPath)
    )
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}
#endif
