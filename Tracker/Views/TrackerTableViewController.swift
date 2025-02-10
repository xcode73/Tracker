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
    case edit(TrackerUI, CategoryUI, String)
}

enum CellPosition {
    case first
    case single
    case last
    case regular
}

protocol TrackerTableViewControllerDelegate: AnyObject {
    func cancelButtonTapped()
    func saveTracker(trackerUI: TrackerUI, categoryUI: CategoryUI)
}

final class TrackerTableViewController: UITableViewController {
    // MARK: - Properties
    weak var delegate: TrackerTableViewControllerDelegate?

    private let categoryStore: CategoryStoreProtocol

    private var tableType: TrackerTableType
    private var titleSectionItems = [""]
    private var tableSectionItems = [String]()

    private var tracker: TrackerUI?
    private var category: CategoryUI?
    private var newTracker = NewTrackerUI()
    private var newCategory = NewCategoryUI()
    private var updatedTracker: TrackerUI?
    private var updatedCategory: CategoryUI?

    private let weekDays = Constants.weekDays
    private let emojis = Constants.emojis
    private let colors = Constants.selectionColors

    private var isDoneButtonEnabled: Bool = false

    // MARK: - UI Components
    private lazy var daysCompletedLabel: UILabel = {
        let view = UILabel()
        view.font = Fonts.ypBold32
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
        categoryStore: CategoryStoreProtocol
    ) {
        self.tableType = tableType
        self.categoryStore = categoryStore

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
            title = NSLocalizedString("vcTitleAddSpecialTracker", comment: "")
            newTracker.date = date
            tableSectionItems = [NSLocalizedString("rowTitleCategory", comment: "")]
            daysCompletedLabel.frame.size.height = 0
        case .regular:
            title = NSLocalizedString("vcTitleAddRegularTracker", comment: "")
            tableSectionItems = [NSLocalizedString("rowTitleCategory", comment: ""),
                                 NSLocalizedString("rowTitleSchedule", comment: "")]
            daysCompletedLabel.frame.size.height = 0
        case .edit(let tracker, let category, let daysCompleted):
            tableView.tableHeaderView = daysCompletedLabel
            daysCompletedLabel.frame.size.height = 70
            daysCompletedLabel.text = daysCompleted

            self.tracker = tracker
            self.category = category

            newTracker = NewTrackerUI(from: tracker)
            newCategory = NewCategoryUI(from: category)

            if tracker.schedule != nil {
                title = NSLocalizedString("vcTitleEditRegularTracker", comment: "")
                tableSectionItems = [NSLocalizedString("rowTitleCategory", comment: ""),
                                     NSLocalizedString("rowTitleSchedule", comment: "")]
            }

            if tracker.date != nil {
                title = NSLocalizedString("vcTitleEditSpecialTracker", comment: "")
                tableSectionItems = [NSLocalizedString("rowTitleCategory", comment: "")]
            }
        }
    }

    private func updateDoneButtonState() {
        if let tracker, let category {
            if let newTrackerTitle = newTracker.title,
               let newTrackerColor = newTracker.color,
               let newTrackerEmoji = newTracker.emoji,
               let newCategoryTitle = newCategory.title,
               let newCategoryId = newCategory.categoryId,
               let newCategoryTrackers = newCategory.trackers,
               newTracker.schedule != nil || newTracker.date != nil {

                if let schedule = newTracker.schedule {
                    updatedTracker = TrackerUI(with: schedule,
                                               id: tracker.id,
                                               title: newTrackerTitle,
                                               color: newTrackerColor,
                                               emoji: newTrackerEmoji,
                                               isPinned: tracker.isPinned)
                    updatedCategory = CategoryUI(categoryID: newCategoryId,
                                                 title: newCategoryTitle,
                                                 trackers: newCategoryTrackers)
                }

                if let date = newTracker.date?.truncated {
                    updatedTracker = TrackerUI(with: date,
                                               id: tracker.id,
                                               title: newTrackerTitle,
                                               color: newTrackerColor,
                                               emoji: newTrackerEmoji,
                                               isPinned: tracker.isPinned)
                    updatedCategory = CategoryUI(categoryID: newCategoryId,
                                                 title: newCategoryTitle,
                                                 trackers: newCategoryTrackers)
                }

                if updatedTracker != tracker || updatedCategory != category {
                    isDoneButtonEnabled = true
                    return
                }
            }
        } else {
            if let newTrackerTitle = newTracker.title,
               let newTrackerColor = newTracker.color,
               let newTrackerEmoji = newTracker.emoji,
               let newCategoryTitle = newCategory.title,
               let newCategoryId = newCategory.categoryId,
               let newCategoryTrackers = newCategory.trackers,
               newTracker.schedule != nil || newTracker.date != nil {

                if let schedule = newTracker.schedule {
                    updatedTracker = TrackerUI(with: schedule,
                                               id: UUID(),
                                               title: newTrackerTitle,
                                               color: newTrackerColor,
                                               emoji: newTrackerEmoji,
                                               isPinned: false)
                    updatedCategory = CategoryUI(categoryID: newCategoryId,
                                                 title: newCategoryTitle,
                                                 trackers: newCategoryTrackers)
                }

                if let date = newTracker.date?.truncated {
                    updatedTracker = TrackerUI(with: date,
                                               id: UUID(),
                                               title: newTrackerTitle,
                                               color: newTrackerColor,
                                               emoji: newTrackerEmoji,
                                               isPinned: false)
                    updatedCategory = CategoryUI(categoryID: newCategoryId,
                                                 title: newCategoryTitle,
                                                 trackers: newCategoryTrackers)
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
                let cell = TitleTableViewCell()
                cell.configure(
                    with: newTracker.title,
                    placeholder: NSLocalizedString("placeholderTracker", comment: "")
                )
                cell.delegate = self
                return cell
            case 1:
                let cell = ErrorTableViewCell()
                cell.configure(with: NSLocalizedString("errorMessageCharacterLimit", comment: ""))
                return cell
            default:
                return UITableViewCell()
            }
        case 1:
            let cell = SettingsTableViewCell()
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
                categoryTitle: newCategory.title,
                selectedWeekDays: newTracker.schedule,
                indexPath: indexPath
            )
            return cell
        case 2:
            let cell = EmojisTableViewCell()
            cell.selectionStyle = .none
            cell.delegate = self
            cell.configure(with: emojis, selectedEmoji: newTracker.emoji)
            return cell
        case 3:
            let cell = ColorsTableViewCell()
            cell.selectionStyle = .none
            cell.delegate = self
            cell.configure(with: colors, selectedColor: newTracker.color)
            return cell
        case 4:
            let cell = ButtonsTableViewCell()
            cell.selectionStyle = .none
            cell.delegate = self

            var doneButtonTitle: String

            switch tableType {
            case .regular, .special:
                doneButtonTitle = NSLocalizedString("buttonAdd", comment: "")
            case .edit:
                doneButtonTitle = NSLocalizedString("buttonSave", comment: "")
            }

            cell.configure(with: doneButtonTitle,
                           cancelButtonTitle: NSLocalizedString("buttonCancel", comment: ""),
                           isDoneButtonEnabled: isDoneButtonEnabled)

            return cell
        default:
            return UITableViewCell()
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 2:
            return NSLocalizedString("sectionHeaderEmoji", comment: "")
        case 3:
            return NSLocalizedString("sectionHeaderColor", comment: "")
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
                let selectedCategory = CategoryUI(from: newCategory)
                let viewController = CategoriesViewController(selectedCategory: selectedCategory)
                let viewModel = CategoriesViewModel(categoryStore: categoryStore)
                viewController.initialize(viewModel: viewModel)
                viewController.delegate = self
                let navigationController = UINavigationController(
                    rootViewController: viewController
                )
                navigationController.modalPresentationStyle = .pageSheet
                present(navigationController, animated: true)
            case 1:
                let viewController = ScheduleViewController(schedule: newTracker.schedule)
                viewController.delegate = self
                let navigationController = UINavigationController(
                    rootViewController: viewController
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
        case 2:
            let cell = SectionHeaderTableViewCell()
            cell.configure(with: NSLocalizedString("sectionHeaderEmoji", comment: ""))
            return cell
        case 3:
            let cell = SectionHeaderTableViewCell()
            cell.configure(with: NSLocalizedString("sectionHeaderColor", comment: ""))
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
            titleSectionItems.append(NSLocalizedString("errorMessageCharacterLimit", comment: ""))
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
    func didSelectCategory(_ categoryUI: CategoryUI) {
        newCategory = NewCategoryUI(from: categoryUI)

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
        guard let updatedTracker, let updatedCategory else { return }

        delegate?.saveTracker(trackerUI: updatedTracker, categoryUI: updatedCategory)
    }
}
