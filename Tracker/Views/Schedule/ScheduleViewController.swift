//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 29.09.2024.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didChangeSchedule(schedule: [WeekDay])
}

final class ScheduleViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: ScheduleViewControllerDelegate?
    private var schedule: [WeekDay]?
    private let weekDays = Constants.weekDays

    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseIdentifier)
        view.separatorStyle = .singleLine
        view.separatorColor = .ypBlack
        view.separatorInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        view.estimatedRowHeight = 75
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var scheduleButton: UIButton = {
        let view = UIButton()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = .ypGray
        view.titleLabel?.font = Constants.Fonts.ypMedium16
        view.setTitleColor(.white, for: .normal)
        view.addTarget(self, action: #selector(didTapCreateScheduleButton), for: .touchUpInside)
        view.setTitle(NSLocalizedString("buttonDone", comment: ""), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init
    init(
        schedule: [WeekDay]?
    ) {
        self.schedule = schedule

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
        title = NSLocalizedString("vcTitleSchedule", comment: "")
        view.backgroundColor = .ypWhite
        addCreateCategoryButton()
        addTableView()
        changeScheduleButtonState()
    }

    private func changeScheduleButtonState() {
        guard let schedule else { return }

        scheduleButton.backgroundColor = schedule.isEmpty ? .ypGray : .ypBlack
        scheduleButton.isEnabled = !schedule.isEmpty
    }

    // MARK: - Actions
    @objc
    private func didTapCreateScheduleButton() {
        guard let schedule else { return }

        delegate?.didChangeSchedule(schedule: schedule)
    }

    // MARK: - Constraints
    private func addCreateCategoryButton() {
        view.addSubview(scheduleButton)

        NSLayoutConstraint.activate([
            scheduleButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            scheduleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            scheduleButton.heightAnchor.constraint(equalToConstant: 60),
            scheduleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func addTableView() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.bottomAnchor.constraint(equalTo: scheduleButton.topAnchor, constant: -16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekDays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ScheduleCell()
        let cellPosition: CellPosition

        switch indexPath.row {
        case 0:
            if weekDays.count == 1 {
                cellPosition = .single
            } else {
                cellPosition = .first
            }
        case weekDays.count - 1:
            cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
            cellPosition = .last
        default:
            cellPosition = .regular
        }

        let isSelected = schedule?.contains(weekDays[indexPath.row]) ?? false

        cell.delegate = self
        cell.configure(
            with: weekDays[indexPath.row],
            selected: isSelected,
            cellPosition: cellPosition
        )

        return cell
    }
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - ScheduleCellDelegate
extension ScheduleViewController: ScheduleCellDelegate {
    func scheduleCellSwitchDidTapped(_ cell: ScheduleCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        let weekDay = weekDays[indexPath.row]

        if let index = schedule?.firstIndex(of: weekDay) {
            schedule?.remove(at: index)
        } else {
            if schedule == nil {
                schedule = [weekDay]
            } else {
                schedule?.append(weekDay)
            }
        }
        changeScheduleButtonState()
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("Empty") {
    let navigationController = UINavigationController(rootViewController: ScheduleViewController(schedule: nil))
    navigationController.modalPresentationStyle = .pageSheet

    return navigationController
}

@available(iOS 17, *)
#Preview("Schedule") {
    let schedule: [WeekDay] = [.monday, .tuesday, .wednesday]
    let navigationController = UINavigationController(rootViewController: ScheduleViewController(schedule: schedule))
    navigationController.modalPresentationStyle = .pageSheet

    return navigationController
}
#endif
