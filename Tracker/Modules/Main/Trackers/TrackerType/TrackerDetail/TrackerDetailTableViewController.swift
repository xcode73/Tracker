//
//  TrackerDetailTableViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 26.09.2024.
//

import UIKit

class TrackerDetailTableViewController: UITableViewController {
    
    // MARK: - Properties
    private var tracker: Tracker?
    private var trackerCategories: [TrackerCategory] = []
    private var isRegular: Bool?
    
    private var trackerSettings = [String]()
    private var titleSectionItems: [String]?
    
    private struct TableData {
        let sectionHeaders: [String]
        let titleSectionItems: [String]
        let errorMessage: String
    }
    
    private var data = TableData(
        sectionHeaders: ["Emoji", "Цвет"],
        titleSectionItems: [""],
        errorMessage: "Ограничение 38 символов"
    )
    
    // MARK: - Initialization
    init(tracker: Tracker?, isRegular: Bool?) {
        self.tracker = tracker
        self.isRegular = isRegular
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 75
        
        registerCells()
        checkTracker()
        setupHideKeyboardOnTap()
        
        titleSectionItems = data.titleSectionItems
        
    }
    
    private func checkTracker() {
        if tracker == nil {
            title = "Новая привычка"
            tracker = Tracker(id: UUID(), name: "", color: "", emoji: "", schedule: nil, daysCompleted: nil)
            
            guard let isRegular else { return }
            
            if isRegular {
                trackerSettings = ["Категория", "Расписание"]
            } else {
                trackerSettings = ["Категория"]
            }
        } else {
            title = "Редактирование привычки"
            let isRegular = tracker?.schedule == nil
            if isRegular {
                trackerSettings = ["Категория", "Расписание"]
            } else {
                trackerSettings = ["Категория"]
            }
        }
    }
    
    /// Call this once to dismiss open keyboards by tapping anywhere in the view controller
    private func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }

    /// Dismisses the keyboard from self.view
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
    
    private func registerCells() {
        tableView.register(TitleCell.self, forCellReuseIdentifier: TitleCell.reuseIdentifier)
        tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.reuseIdentifier)
        tableView.register(ButtonsTableViewCell.self, forCellReuseIdentifier: ButtonsTableViewCell.reuseIdentifier)
        tableView.register(EmojisTableViewCell.self, forCellReuseIdentifier: EmojisTableViewCell.reuseIdentifier)
        tableView.register(SectionHeaderTableViewCell.self, forCellReuseIdentifier: SectionHeaderTableViewCell.reuseIdentifier)
        tableView.register(ColorsTableViewCell.self, forCellReuseIdentifier: ColorsTableViewCell.reuseIdentifier)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return titleSectionItems?.count ?? 0
        case 1:
            return trackerSettings.count
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            switch indexPath.row {
                case 0:
                    let cell = TitleCell()
                    cell.configure(with: tracker)
                    cell.delegate = self
                    return cell
                case 1:
                    let cell = ErrorCell()
                    return cell
                default:
                    return UITableViewCell()
            }
        case 1:
            let cell = SettingsCell()
            guard let isRegular = isRegular else {
                return UITableViewCell()
            }
            
            cell.configure(with: trackerSettings[indexPath.row], isRegular: isRegular)
            return cell
        case 2:
            let cell = EmojisTableViewCell()
            return cell
        case 3:
            let cell = ColorsTableViewCell()
            return cell
        case 4:
            let cell = ButtonsTableViewCell()
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 2:
            return "Emoji"
        case 3:
            return "Цвет"
        default:
            return nil
        }
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let trackerSettings = trackerSettings[indexPath.row]
            switch trackerSettings {
            case "Категория":
                let navigationController = UINavigationController(rootViewController: CategoriesViewController())
                navigationController.modalPresentationStyle = .pageSheet
                present(navigationController, animated: true)
            case "Расписание":
                let navigationController = UINavigationController(rootViewController: ScheduleViewController())
                navigationController.modalPresentationStyle = .pageSheet
                present(navigationController, animated: true)
            default:
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return 75
            case 1:
                return 38
            default:
                return 75
            }
        case 2, 3:
            return 40
        default:
            return 75
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 2, 3:
            return 75
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 2, 3:
            let cell = SectionHeaderTableViewCell()
            cell.configure(with: data.sectionHeaders[section - 2])
            return cell
        default:
            return nil
        }
    }
}

// MARK: - TitleCellDelegate
extension TrackerDetailTableViewController: TitleCellDelegate {
    func titleChanged(title: String?) {
        guard let title,
              let items = titleSectionItems?.count else {
            return
        }
        
        switch title.count {
        case 0...37:
            if items > 1 {
                titleSectionItems?.removeLast()
                tableView.performBatchUpdates {
                    tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                } completion: { _ in }
            }
            titleSectionItems = [title]
        case 38:
            titleSectionItems?.append(data.errorMessage)
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
#Preview("Special") {
    let navigationController = UINavigationController(rootViewController: TrackerDetailTableViewController(tracker: nil, isRegular: false))
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}

@available(iOS 17, *)
#Preview("Regular") {
    let navigationController = UINavigationController(rootViewController: TrackerDetailTableViewController(tracker: nil, isRegular: true))
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}
#endif
