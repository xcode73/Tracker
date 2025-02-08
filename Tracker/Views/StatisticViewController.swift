//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 23.09.2024.
//

import UIKit

final class StatisticViewController: UIViewController {
    // MARK: - Properties
    private var statisticStore: StatisticStoreProtocol
    private let analyticsService: AnalyticsServiceProtocol

    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(StatisticTableViewCell.self, forCellReuseIdentifier: StatisticTableViewCell.reuseIdentifier)
        view.backgroundColor = .clear
        view.separatorStyle = .none
        view.rowHeight = 102
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
        view.image = .icCrying
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var placeholderLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.font = Fonts.ypMedium12
        view.textAlignment = .center
        view.textColor = .ypBlack
        view.text = NSLocalizedString("placeholderStatistics", comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init
    init(
        statisticStore: StatisticStoreProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.statisticStore = statisticStore
        self.analyticsService = analyticsService

        super.init(nibName: nil, bundle: nil)
        self.statisticStore.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateStatistics()
        showPlaceholderIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        analyticsService.report(event: .open, screen: .statistics)
    }

    private func showPlaceholderIfNeeded() {
        do {
            if try statisticStore.fetchNumberOfRecords() == 0 {
                placeholderStackView.isHidden = false
                tableView.isHidden = true
            } else {
                placeholderStackView.isHidden = true
                tableView.isHidden = false
            }
        } catch {
            showStoreErrorAlert(error.localizedDescription)
        }
    }

    private func setupStatisticsIfNeeded() {
        do {
            try statisticStore.setupStatisticStore()
        } catch {
            showStoreErrorAlert(error.localizedDescription)
        }
    }

    private func updateStatistics() {
        do {
            try statisticStore.calculateStatistics()
        } catch {
            showStoreErrorAlert(error.localizedDescription)
        }
    }

    private func setupUI() {
        view.backgroundColor = .ypWhite
        setupLayout()
        setupPlaceholderViewConstraints()
        setupTableViewConstraints()
    }

    // MARK: - Alerts
    func showStoreErrorAlert(_ message: String) {
        let model = AlertModel(
            title: NSLocalizedString("alertTitleStoreError", comment: ""),
            message: message,
            buttons: [.cancelButton],
            identifier: "Tracker Store Error Alert",
            completion: nil
        )

        AlertPresenter.showAlert(on: self, model: model)
    }

    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(placeholderStackView)
        placeholderStackView.addArrangedSubview(placeholderImageView)
        placeholderStackView.addArrangedSubview(placeholderLabel)
        view.addSubview(tableView)
    }

    private func setupPlaceholderViewConstraints() {
        NSLayoutConstraint.activate([
            placeholderStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    private func setupTableViewConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource
extension StatisticViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statisticStore.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: StatisticTableViewCell.reuseIdentifier,
                                                     for: indexPath) as? StatisticTableViewCell
        else {
            return UITableViewCell()
        }

        let statisticUI = statisticStore.fetchStatisticUI(at: indexPath)

        cell.backgroundColor = .clear
        cell.configure(with: statisticUI)

        return cell
    }
}

// MARK: - UITableViewDelegate
extension StatisticViewController: UITableViewDelegate {}

// MARK: - TrackerStoreDelegate
extension StatisticViewController: StatisticStoreDelegate {
    func didUpdate(_ updates: [StatisticStoreUpdate]) {
        tableView.performBatchUpdates {
            for update in updates {
                switch update {
                case let .updated(at: indexPath):
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                default:
                    break
                }
            }
        }
    }
}
