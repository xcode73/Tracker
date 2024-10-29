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
    case edit(Tracker, TrackerCategory, Int)
}

enum CellPosition {
    case first
    case single
    case last
    case regular
}

protocol TrackerTableViewControllerDelegate: AnyObject {
    func didTapDoneButton(categories: [TrackerCategory])
}

final class TrackerTableViewController: UITableViewController {
    // MARK: - Properties
    weak var delegate: TrackerTableViewControllerDelegate?
    
    private var tableType: TrackerTableType
    private var categories: [TrackerCategory]
    
    private var titleSectionItems = [""]
    private var tableSectionItems = [String]()
    
    private var tracker: Tracker?
    
    private var trackerId = UUID()
    
    private var trackerTitle: String?
    
    private var selectedCategory: TrackerCategory?
    
    private let weekDays = Constants.weekDays
    private var selectedWeekDays: [WeekDay]?
    
    private var currentDate: Date?
    
    private let emojis = Constants.emojis
    private var selectedEmoji: String?
    
    private let colors = Constants.selectionColors
    private var selectedColor: String?
    
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
    
    // MARK: - Init
    init(
        tableType: TrackerTableType,
        categories: [TrackerCategory]
    ) {
        self.tableType = tableType
        self.categories = categories
        
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
        registerCells()
        
        switch tableType {
        case .special(let date):
            title = LocalConst.Add.specialTableTitle
            currentDate = date
            tableSectionItems = ["Категория"]
            daysCompletedLabel.frame.size.height = 0
        case .regular:
            title = LocalConst.Add.regularTableTitle
            tableSectionItems = ["Категория", "Расписание"]
            daysCompletedLabel.frame.size.height = 0
        case .edit(let tracker, let category, let completedTimes):
            self.tracker = tracker
            self.trackerId = tracker.id
            self.trackerTitle = tracker.title
            self.selectedCategory = category
            
            if let schedule = tracker.schedule {
                self.selectedWeekDays = schedule
            }
            
            if let trackerDate = tracker.date {
                currentDate = trackerDate
            }
            
            if let trackerSchedule = tracker.schedule {
                title = LocalConst.Edit.regularTableTitle
                tableSectionItems = ["Категория", "Расписание"]
                selectedWeekDays = trackerSchedule
            } else {
                title = LocalConst.Edit.specialTableTitle
                tableSectionItems = ["Категория"]
            }

            selectedEmoji = tracker.emoji
            selectedColor = tracker.color
            
            tableView.tableHeaderView = daysCompletedLabel
            daysCompletedLabel.frame.size.height = 70
            
            var title: String
            let lastDigit = completedTimes % 10
            
            switch lastDigit {
            case 1:
                title = "день"
            case 2, 3, 4:
                title = "дня"
            case 5, 6, 7, 8, 9, 0:
                title = "дней"
            default:
                title = "дней"
            }
            
            daysCompletedLabel.text = "\(completedTimes) " + title
        }
    }
    
    private func changeDoneButtonState() {
        guard let trackerTitle else {
            isDoneButtonEnabled = false
            return
        }
        
        if trackerTitle != tracker?.title &&
            trackerTitle.count > 0 &&
            trackerTitle != " " &&
            selectedCategory != nil &&
            selectedEmoji != nil &&
            selectedColor != nil &&
            selectedWeekDays != nil ||
            currentDate != nil
        {
            isDoneButtonEnabled = true
        } else {
            isDoneButtonEnabled = false
        }
    }
    
    // MARK: - Register cells
    private func registerCells() {
        tableView.register(SectionHeaderTableViewCell.self, forCellReuseIdentifier: SectionHeaderTableViewCell.reuseIdentifier)
        tableView.register(TitleCell.self, forCellReuseIdentifier: TitleCell.reuseIdentifier)
        tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.reuseIdentifier)
        tableView.register(ButtonsCell.self, forCellReuseIdentifier: ButtonsCell.reuseIdentifier)
        tableView.register(EmojisCell.self, forCellReuseIdentifier: EmojisCell.reuseIdentifier)
        tableView.register(ColorsCell.self, forCellReuseIdentifier: ColorsCell.reuseIdentifier)
    }

    // MARK: - Table view data source
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
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = TitleCell()
                cell.configure(
                    with: trackerTitle,
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
                category: selectedCategory,
                selectedWeekDays: selectedWeekDays,
                indexPath: indexPath
            )
            return cell
        case 2:
            let cell = EmojisCell()
            cell.selectionStyle = .none
            cell.delegate = self
            cell.configure(with: emojis, selectedEmoji: selectedEmoji)
            return cell
        case 3:
            let cell = ColorsCell()
            cell.selectionStyle = .none
            cell.delegate = self
            cell.configure(with: colors, selectedColor: selectedColor)
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                let vc = CategoriesViewController(categories: categories, selectedCategory: selectedCategory)
                vc.delegate = self
                let navigationController = UINavigationController(
                    rootViewController: vc
                )
                navigationController.modalPresentationStyle = .pageSheet
                present(navigationController, animated: true)
            case 1:
                let vc = ScheduleViewController(schedule: selectedWeekDays)
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 2, 3:
            return 18
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
        trackerTitle = title
        tableView.reloadData()
        changeDoneButtonState()
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
    func didSelectCategory(selectedCategory: TrackerCategory, categories: [TrackerCategory]) {
        self.selectedCategory = selectedCategory
        self.categories = categories
        
        tableView.reloadData()
        changeDoneButtonState()
        dismiss(animated: true)
    }
}

// MARK: - ScheduleViewControllerDelegate
extension TrackerTableViewController: ScheduleViewControllerDelegate {
    func didChangeSchedule(schedule: [WeekDay]) {
        
        selectedWeekDays = schedule
        tableView.reloadData()
        changeDoneButtonState()
        dismiss(animated: true)
    }
}

// MARK: - EmojisCellDelegate
extension TrackerTableViewController: EmojisCellDelegate {
    func didSelectEmoji(emoji: String) {
        selectedEmoji = emoji
        tableView.reloadData()
        changeDoneButtonState()
    }
}

// MARK: - ColorsCellDelegate
extension TrackerTableViewController: ColorsCellDelegate {
    func didSelectColor(color: String) {
        selectedColor = color
        tableView.reloadData()
        changeDoneButtonState()
    }
}

// MARK: - ButtonsCellDelegate
extension TrackerTableViewController: ButtonsCellDelegate {
    func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    func didTapDoneButton() {
        guard
            let trackerTitle,
            let selectedCategory,
            let selectedEmoji,
            let selectedColor
        else {
            return
        }
        
        switch tableType {
        case .special:
            tracker = Tracker(
                id: trackerId,
                title: trackerTitle,
                color: selectedColor,
                emoji: selectedEmoji,
                schedule: nil,
                date: currentDate
            )
        case .regular:
            tracker = Tracker(
                id: trackerId,
                title: trackerTitle,
                color: selectedColor,
                emoji: selectedEmoji,
                schedule: selectedWeekDays,
                date: nil
            )
        case .edit:
            if let selectedWeekDays {
                tracker = Tracker(
                    id: trackerId,
                    title: trackerTitle,
                    color: selectedColor,
                    emoji: selectedEmoji,
                    schedule: selectedWeekDays,
                    date: nil
                )
            }
            
            if let currentDate {
                tracker = Tracker(
                    id: trackerId,
                    title: trackerTitle,
                    color: selectedColor,
                    emoji: selectedEmoji,
                    schedule: nil,
                    date: currentDate
                )
            }
        }
        
        var updatedCategories = [TrackerCategory]()
        
        for category in categories {
            if category.id == selectedCategory.id {
                guard let tracker else { return }
                
                var updatedTrackers = [Tracker]()
                for categoryTracker in category.trackers {
                    if categoryTracker.id == trackerId {
                        
                        
                        updatedTrackers.append(tracker)
                    } else {
                        updatedTrackers.append(categoryTracker)
                    }
                }
                
                if !updatedTrackers.contains(where: { $0.id == trackerId }) {
                    updatedTrackers.append(tracker)
                }
                
                updatedCategories.append(TrackerCategory(id: category.id, title: category.title, trackers: updatedTrackers))
            } else {
                updatedCategories.append(category)
            }
        }
        
        categories = updatedCategories

        delegate?.didTapDoneButton(categories: categories)
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("Special") {
    let categories: [TrackerCategory] = [
        TrackerCategory(id: UUID(), title: "Baz", trackers: []),
        TrackerCategory(id: UUID(), title: "Bar", trackers: []),
    ]
    let navigationController = UINavigationController(rootViewController: TrackerTableViewController(tableType: .special(Date()), categories: categories))
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}

@available(iOS 17, *)
#Preview("Regular") {
    let categories: [TrackerCategory] = [
        TrackerCategory(id: UUID(), title: "Baz", trackers: []),
        TrackerCategory(id: UUID(), title: "Bar", trackers: []),
    ]
    let navigationController = UINavigationController(rootViewController: TrackerTableViewController(tableType: .regular, categories: categories))
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}

@available(iOS 17, *)
#Preview("Edit Regular") {
    let selectedCategory = TrackerCategory(id: UUID(), title: "Foo", trackers: [
        Tracker(
            id: UUID(),
            title: "Lorem ipsum dolor sit amet, consetetur",
            color: Constants.selectionColors[4],
            emoji: Constants.emojis[0],
            schedule: [WeekDay.tuesday, WeekDay.friday],
            date: nil
        )
    ])
    let categories: [TrackerCategory] = [
        selectedCategory,
        TrackerCategory(id: UUID(), title: "Baz", trackers: []),
        TrackerCategory(id: UUID(), title: "Bar", trackers: []),
    ]
    
    let tracker = categories[0].trackers[0]
    let navigationController = UINavigationController(rootViewController: TrackerTableViewController(tableType: .edit(tracker, selectedCategory, 2), categories: categories))
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}

@available(iOS 17, *)
#Preview("Edit Special") {
    let selectedCategory = TrackerCategory(id: UUID(), title: "Foo", trackers: [
        Tracker(
            id: UUID(),
            title: "Lorem ipsum dolor",
            color: Constants.selectionColors[4],
            emoji: Constants.emojis[0],
            schedule: nil,
            date: Date()
        )
    ])
    let categories: [TrackerCategory] = [
        selectedCategory,
        TrackerCategory(id: UUID(), title: "Baz", trackers: []),
        TrackerCategory(id: UUID(), title: "Bar", trackers: []),
    ]
    
    let tracker = categories[0].trackers[0]
    let navigationController = UINavigationController(rootViewController: TrackerTableViewController(tableType: .edit(tracker, selectedCategory, 2), categories: categories))
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}
#endif
