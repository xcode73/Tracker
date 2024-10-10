//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 28.09.2024.
//

import UIKit

class CategoriesViewController: UIViewController {
    // MARK: - Properties
//    private let trackers: [Tracker] = []
    private var categories: [TrackerCategory]?
    
    // MARK: - UI Components
    private lazy var categoriesTableView: UITableView = {
        let view = UITableView()
        view.dataSource = self
        view.delegate = self
        view.separatorStyle = .none
        view.backgroundColor = .ypBackground
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
        view.font = .systemFont(ofSize: 12, weight: .medium)
        view.textAlignment = .center
        view.textColor = .ypBlack
        view.text = "Привычки и события можно \n объединить по смыслу"
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let view = UIButton()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = .ypBlack
        view.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        view.setTitleColor(.white, for: .normal)
        view.setTitle("Добавить категорию", for: .normal)
        view.addTarget(CategoriesViewController.self, action: #selector(switchToAddCategoryViewController), for: .touchUpInside)
        view.accessibilityIdentifier = "Add Category Button"
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    func setupUI() {
        title = "Категория"
        view.backgroundColor = .ypWhite
        addAddCategoryButton()
        
        if categories == nil {
            addPlaceholder()
        } else {
            addCategoriesTableView()
        }
    }
    
    // MARK: - Constraints
    private func addCategoriesTableView() {
        view.addSubview(categoriesTableView)
        
        NSLayoutConstraint.activate([
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoriesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoriesTableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor)
        ])
    }
    
    private func addPlaceholder() {
        view.addSubview(placeholderStackView)
        placeholderStackView.addArrangedSubview(placeholderImageView)
        placeholderStackView.addArrangedSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func addAddCategoryButton() {
        view.addSubview(addCategoryButton)
        
        NSLayoutConstraint.activate([
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32)
        ])
    }
    
    // MARK: - Actions
    @objc
    private func switchToAddCategoryViewController() {
//        let viewController = WebViewController()
//        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CategoriesTableViewCell()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Preview
@available(iOS 17, *)
#Preview() {
    let navigationController = UINavigationController(rootViewController: CategoriesViewController())
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}
