//
//  TrackerTypeViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 23.09.2024.
//

import UIKit

protocol TrackerTypeViewControllerDelegate: AnyObject {
    func cancelButtonTapped()
    func saveTracker(trackerUI: TrackerUI, categoryUI: CategoryUI)
}

final class TrackerTypeViewController: UIViewController {
    weak var delegate: TrackerTypeViewControllerDelegate?
    private var currentDate: Date
    private let categoryStore: CategoryStoreProtocol

    // MARK: - UI Components
    private lazy var buttonsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 19
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var regularEventButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("buttonRegularTracker", comment: ""), for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapRegularButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var nonRegularEventButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("buttonSpecialTracker", comment: ""), for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapNonRegularButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init
    init(
        categoryStore: CategoryStoreProtocol,
        currentDate: Date
    ) {
        self.categoryStore = categoryStore
        self.currentDate = currentDate

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

    // MARK: - Actions
    @objc
    private func didTapRegularButton() {
        let viewController = TrackerTableViewController(tableType: .regular,
                                                        categoryStore: categoryStore)
        viewController.delegate = self
        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }

    @objc
    private func didTapNonRegularButton() {
        let viewController = TrackerTableViewController(tableType: .special(currentDate),
                                                        categoryStore: categoryStore)
        viewController.delegate = self
        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        navigationController.modalPresentationStyle = .pageSheet

        present(navigationController, animated: true)
    }

    // MARK: - Constraints
    private func setupUI() {
        title = NSLocalizedString("trackerType.title", comment: "")
        view.backgroundColor = .ypWhite
        view.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(regularEventButton)
        buttonsStackView.addArrangedSubview(nonRegularEventButton)

        NSLayoutConstraint.activate([
            buttonsStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.88),
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            regularEventButton.heightAnchor.constraint(equalToConstant: 60),
            nonRegularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

extension TrackerTypeViewController: TrackerTableViewControllerDelegate {
    func cancelButtonTapped() {
        delegate?.cancelButtonTapped()
        dismiss(animated: true)
    }

    func saveTracker(trackerUI: TrackerUI, categoryUI: CategoryUI) {
        delegate?.saveTracker(trackerUI: trackerUI, categoryUI: categoryUI)
        dismiss(animated: true)
    }
}
