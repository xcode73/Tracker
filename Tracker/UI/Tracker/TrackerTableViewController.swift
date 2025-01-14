//
//  TrackerTableViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 26.09.2024.
//

import UIKit

enum TrackerTableType {
    case special(Date)
    case regular
    case edit(Tracker, String)
}

enum CellPosition {
    case first
    case single
    case last
    case regular
}

protocol TrackerTableViewControllerDelegate: AnyObject {
    func cancelButtonTapped()
    func createTracker(tracker: Tracker)
    func updateTracker(tracker: Tracker, at indexPath: IndexPath)
}

final class TrackerTableViewController: UITableViewController {
    // MARK: - Properties
    weak var delegate: TrackerTableViewControllerDelegate?
    
    private var tableType: TrackerTableType
    private var indexPath: IndexPath?
    private var trackerDataStore: TrackerDataStore
    
    private var titleSectionItems = [""]
    private var tableSectionItems = [String]()
    
    private var tracker: Tracker?
    private var newTracker = NewTracker()
    private var updatedTracker: Tracker?
    
    private let weekDays = Constants.weekDays
    private let emojis = Constants.emojis
    private let colors = Constants.selectionColors
    
    private var isDoneButtonEnabled: Bool = false
    
    private enum LocalConst {
        enum Edit {
            static let specialTableTitle = "Редактирование нерегулярного события"
            static let regularTableTitle = "Редактирование привычки"
            static let doneButtonTitle = "Сохранить"
        }
        enum Add {
            static let specialTableTitle = "Новое нерегулярное событие"
            static let regularTableTitle = "Новая привычка"
            static let doneButtonTitle = "Создать"
        }
        
        static let cancelButtonTitle = "Отменить"
        static let sectionHeaders = ["Emoji", "Цвет"]
        static let titleCellPlaceholder = "Введите название трекера"
        static let errorCellTitle = "Ограничение 38 символов"
    }
    
    // MARK: - UI Components
    private lazy var daysCompletedLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Fonts.ypBold32
        view.textColor = .ypBlack
        view.textAlignment = .center
        
        return view
    }()
    
    private lazy var tap: UITapGestureRecognizer = {
        let view = UITapGestureRecognizer()
        view.addTarget(self, action: #selector(hideKeyboard))
        
        return view
    }()
    
    // MARK: - Init
    init(
        tableType: TrackerTableType,
        trackerDataStore: TrackerDataStore,
        indexPath: IndexPath?
    ) {
        self.tableType = tableType
        self.trackerDataStore = trackerDataStore
        self.indexPath = indexPath
        
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
    
    // MARK: - Setup
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        switch tableType {
        case .special(let date):
            title = LocalConst.Add.specialTableTitle
            newTracker.date = date
            tableSectionItems = ["Категория"]
            daysCompletedLabel.frame.size.height = 0
        case .regular:
            title = LocalConst.Add.regularTableTitle
            tableSectionItems = ["Категория", "Расписание"]
            daysCompletedLabel.frame.size.height = 0
        case .edit(let tracker, let daysCompleted):
            tableView.tableHeaderView = daysCompletedLabel
            daysCompletedLabel.frame.size.height = 70
            daysCompletedLabel.text = daysCompleted
            
            self.tracker = tracker
            newTracker = NewTracker(from: tracker)
            
            if tracker.schedule != nil {
                title = LocalConst.Edit.regularTableTitle
                tableSectionItems = ["Категория", "Расписание"]
            }
            
            if tracker.date != nil {
                title = LocalConst.Edit.specialTableTitle
                tableSectionItems = ["Категория"]
            }
        }
    }
    
    private func updateDoneButtonState() {
        if let tracker {
            if let newTrackerTitle = newTracker.title,
               let newTrackerCategoryTitle = newTracker.categoryTitle,
               let newTrackerColor = newTracker.color,
               let newTrackerEmoji = newTracker.emoji,
               newTracker.schedule != nil || newTracker.date != nil {
                
                if let schedule = newTracker.schedule {
                    updatedTracker = Tracker(with: schedule,
                                             id: tracker.id,
                                             categoryTitle: newTrackerCategoryTitle,
                                             title: newTrackerTitle,
                                             color: newTrackerColor,
                                             emoji: newTrackerEmoji)
                }
                
                if let date = newTracker.date?.truncated {
                    updatedTracker = Tracker(with: date,
                                             id: tracker.id,
                                             categoryTitle: newTrackerCategoryTitle,
                                             title: newTrackerTitle,
                                             color: newTrackerColor,
                                             emoji: newTrackerEmoji)
                }
                
                if updatedTracker != tracker {
                    isDoneButtonEnabled = true
                    return
                }
            }
        } else {
            if let newTrackerTitle = newTracker.title,
               let newTrackerCategoryTitle = newTracker.categoryTitle,
               let newTrackerColor = newTracker.color,
               let newTrackerEmoji = newTracker.emoji,
               newTracker.schedule != nil || newTracker.date != nil {
                
                if let schedule = newTracker.schedule {
                    updatedTracker = Tracker(with: schedule,
                                             id: UUID(),
                                             categoryTitle: newTrackerCategoryTitle,
                                             title: newTrackerTitle,
                                             color: newTrackerColor,
                                             emoji: newTrackerEmoji)
                }
                
                if let date = newTracker.date?.truncated {
                    updatedTracker = Tracker(with: date,
                                             id: UUID(),
                                             categoryTitle: newTrackerCategoryTitle,
                                             title: newTrackerTitle,
                                             color: newTrackerColor,
                                             emoji: newTrackerEmoji)
                }
                
                isDoneButtonEnabled = true
                return
            }
        }
        
        isDoneButtonEnabled = false
    }
    
    // MARK: - Actions
    @objc
    private func hideKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableType {
        case .special, .regular, .edit:
            switch section {
            case 0:
                return titleSectionItems.count
            case 1:
                return tableSectionItems.count
            default:
                return 1
            }
        }
    }
    
    // MARK: - CellForRow
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = TitleCell()
                cell.configure(
                    with: newTracker.title,
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
        case 1:
            let cell = SettingsCell()
            let cellPosition: CellPosition
            
            switch indexPath.row {
            case 0:
                if tableSectionItems.count == 1 {
                    cellPosition = .single
                } else {
                    cellPosition = .first
                }
            case tableSectionItems.count - 1:
                cellPosition = .last
            default:
                cellPosition = .regular
            }
            
            cell.configure(
                itemTitle: tableSectionItems[indexPath.row],
                cellPosition: cellPosition,
                categoryTitle: newTracker.categoryTitle,
                selectedWeekDays: newTracker.schedule,
                indexPath: indexPath
            )
            return cell
        case 2:
            let cell = EmojisCell()
            cell.selectionStyle = .none
            cell.delegate = self
            cell.configure(with: emojis, selectedEmoji: newTracker.emoji)
            return cell
        case 3:
            let cell = ColorsCell()
            cell.selectionStyle = .none
            cell.delegate = self
            cell.configure(with: colors, selectedColor: newTracker.color)
            return cell
        case 4:
            let cell = ButtonsCell()
            cell.selectionStyle = .none
            cell.delegate = self
            
            var doneButtonTitle: String

            switch tableType {
            case .regular, .special:
                doneButtonTitle = LocalConst.Add.doneButtonTitle
            case .edit:
                doneButtonTitle = LocalConst.Edit.doneButtonTitle
            }
            
            cell.configure(with: doneButtonTitle, cancelButtonTitle: LocalConst.cancelButtonTitle, isDoneButtonEnabled: isDoneButtonEnabled)
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 2, 3:
            return LocalConst.sectionHeaders[section]
        default:
            return nil
        }
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                let vc = CategoriesViewController(selectedCategoryTitle: newTracker.categoryTitle,
                                                  trackerDataStore: trackerDataStore)
                vc.delegate = self
                let navigationController = UINavigationController(
                    rootViewController: vc
                )
                navigationController.modalPresentationStyle = .pageSheet
                present(navigationController, animated: true)
            case 1:
                let vc = ScheduleViewController(schedule: newTracker.schedule)
                vc.delegate = self
                let navigationController = UINavigationController(
                    rootViewController: vc
                )
                navigationController.modalPresentationStyle = .pageSheet
                present(navigationController, animated: true)
            default:
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 1:
                return 38
            default:
                return 75
            }
        case 2, 3:
            return 204
        default:
            return 75
        }
    }
    
    override func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        switch section {
        case 2, 3:
            return 18
        default:
            return 0
        }
    }
    
    override func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        switch section {
        case 2, 3:
            let cell = SectionHeaderTableViewCell()
            cell.configure(with: LocalConst.sectionHeaders[section - 2])
            return cell
        default:
            return nil
        }
    }
}

// MARK: - TitleCellDelegate
extension TrackerTableViewController: TitleCellDelegate {
    func didTapDoneButton(title: String) {
        newTracker.title = title
        
        tableView.reloadData()
        updateDoneButtonState()
    }
    
    func titleChanged(title: String) {
        let items = titleSectionItems.count
        
        switch title.count {
        case 0...37:
            if items > 1 {
                titleSectionItems.removeLast()
                tableView.performBatchUpdates {
                    tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                } completion: { _ in }
            }
            titleSectionItems = [title]
        case 38:
            titleSectionItems.append(LocalConst.errorCellTitle)
            tableView.performBatchUpdates {
                tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            } completion: { _ in }
        default:
            break
        }
    }
}

// MARK: - CategoriesViewControllerDelegate
extension TrackerTableViewController: CategoriesViewControllerDelegate {
    func didSelectCategory(selectedCategoryTitle: String) {
        newTracker.categoryTitle = selectedCategoryTitle
        
        tableView.reloadData()
        updateDoneButtonState()
        dismiss(animated: true)
    }
}

// MARK: - ScheduleViewControllerDelegate
extension TrackerTableViewController: ScheduleViewControllerDelegate {
    func didChangeSchedule(schedule: [WeekDay]) {
        newTracker.schedule = schedule
        
        tableView.reloadData()
        updateDoneButtonState()
        dismiss(animated: true)
    }
}

// MARK: - EmojisCellDelegate
extension TrackerTableViewController: EmojisCellDelegate {
    func didSelectEmoji(emoji: String) {
        newTracker.emoji = emoji
        
        tableView.reloadData()
        updateDoneButtonState()
    }
}

// MARK: - ColorsCellDelegate
extension TrackerTableViewController: ColorsCellDelegate {
    func didSelectColor(color: String) {
        newTracker.color = color
        
        tableView.reloadData()
        updateDoneButtonState()
    }
}

// MARK: - ButtonsCellDelegate
extension TrackerTableViewController: ButtonsCellDelegate {
    func didTapCancelButton() {
        delegate?.cancelButtonTapped()
    }
    
    func didTapDoneButton() {
        guard let updatedTracker else { return }
        
        if let indexPath {
            delegate?.updateTracker(tracker: updatedTracker, at: indexPath)
        } else {
            delegate?.createTracker(tracker: updatedTracker)
        }
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("Special") {
    let trackerDataStore = (UIApplication.shared.delegate as! AppDelegate).trackerDataStore
    let vc = TrackerTableViewController(tableType: .special(Date()), trackerDataStore: trackerDataStore, indexPath: nil)
    let navigationController = UINavigationController(rootViewController: vc)
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}

@available(iOS 17, *)
#Preview("Regular") {
    let trackerDataStore = (UIApplication.shared.delegate as! AppDelegate).trackerDataStore
    let vc = TrackerTableViewController(tableType: .regular, trackerDataStore: trackerDataStore, indexPath: nil)
    let navigationController = UINavigationController(rootViewController: vc)
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}
#endif
