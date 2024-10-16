//
//  DetailTableViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 26.09.2024.
//

import UIKit

enum DetailTableType {
//    case trackerDetail(Tracker?, TrackerCategory?, Int?, Bool)
    case special
    case regular
    case edit(Tracker, TrackerCategory, Int)
    case categories(TrackerCategory?)
    case categoryDetail
    case schedule(Tracker)
}

enum CellPosition {
    case first
    case single
    case last
    case regular
}

enum TableCellType {
    case chevron
    case checkmark
    case `switch`
}

final class DetailTableViewController: UITableViewController {
    // MARK: - Properties
    private var tableType: DetailTableType
    private var trackerStorage = TrackerStorage()
    private var categories: [TrackerCategory]?
    private var selectedCategory: TrackerCategory?
    private var tracker: Tracker?
    private let currentDate: Date?
    
    private var titleSectionItems = [""]
    private var tableSectionItems = [String]()
    
    private let sectionHeaders = ["Emoji", "Цвет"]
    private let errorMessage = "Ограничение 38 символов"
    private let weekDays = Constants.weekDays
    private var selectedWeekDays = [WeekDay]()
    private let emojis = Constants.emojis
    private var selectedEmoji = String()
    private let colors = Constants.selectionColors
    private var selectedColor = String()
    
    private enum DetailTableConstants {
        enum Tracker {
            enum Edit {
                static let specialTableTitle = "Редактирование нерегулярного события"
                static let regularTableTitle = "Редактирование привычки"
            }
            enum Add {
                static let specialTableTitle = "Новое нерегулярное событие"
                static let regularTableTitle = "Новая привычка"
            }
            
            static let sectionHeaders = ["Emoji", "Цвет"]
            static let titelCellPlaceholder = "Введите название трекера"
        }
        
        enum Category {
            static let titelCellPlaceholder = "Введите название категории"
        }
        
        static let ErrorCellTitel = "Ограничение 38 символов"
        
        static let trackerTitelPlaceholder = "Введите название трекера"
        static let categoryTitlePlaceholder = "Введите название категории"
        static let titleSectionErrorMassage = "Ограничение 38 символов"
        static let sectionHeaders = ["Emoji", "Цвет"]
        static let tablePlaceholderLabel = "Привычки и события можно \n объединить по смыслу"
        static let specialTitle = "Новое нерегулярное событие"
        static let regularTitle = "Новая привычка"
        static let trackerDetailTitle = "Редактирование привычки"
        static let categoriesTitle = "Категории"
        static let categoryDetailTitle = "Новая категория"
    }
    
    // MARK: - UI Components
    private lazy var daysCompletedLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 32, weight: .bold)
        view.textColor = .ypBlack
        view.textAlignment = .center
        
        return view
    }()
    
    private lazy var placeholderStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .center
        view.spacing = 16
        view.isHidden = true
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
        view.text = DetailTableConstants.tablePlaceholderLabel
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var createCategoryButton: UIButton = {
        let view = UIButton()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = .ypBlack
        view.titleLabel?.font = Constants.Fonts.ypMedium16
        view.setTitleColor(.white, for: .normal)
        view.addTarget(self, action: #selector(switchToAddCategoryViewController), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // MARK: - Init
    init(
        tableType: DetailTableType,
        categories: [TrackerCategory]?,
        currentDate: Date?
    ) {
        self.tableType = tableType
        self.categories = categories
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
    
    private func setupUI() {
        setupTableView()
        setupHideKeyboardOnTap()
        addPlaceholder()
        addCreateCategoryButton()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        registerCells()
        
        switch tableType {
//        case .trackerDetail(let tracker, let category, let completedTimes, let isRegular):
//            if let tracker, let category, let completedTimes {
//                if isRegular {
//                    title = DetailTableConstants.Tracker.Edit.regularTableTitle
//                    tableSectionItems = ["Категория", "Расписание"]
//                    selectedWeekDays = tracker.schedule
//                } else {
//                    title = DetailTableConstants.Tracker.Edit.specialTableTitle
//                    tableSectionItems = ["Категория"]
//                }
//            } else {
//                if isRegular {
//                    title = DetailTableConstants.Tracker.Add.regularTableTitle
//                    tableSectionItems = ["Категория", "Расписание"]
//                    daysCompletedLabel.frame.size.height = 0
//                    createCategoryButton.isHidden = true
//                } else {
//                    title = DetailTableConstants.Tracker.Add.specialTableTitle
//                    tableSectionItems = ["Категория"]
//                    if let currentDate = currentDate {
//                        selectedWeekDays = [WeekDay(date: currentDate)]
//                    }
//                    daysCompletedLabel.frame.size.height = 0
//                    createCategoryButton.isHidden = true
//                }
//            }
        case .special:
            title = DetailTableConstants.specialTitle
            tableSectionItems = ["Категория"]
            if let currentDate = currentDate {
                selectedWeekDays = [WeekDay(date: currentDate)]
            }
            daysCompletedLabel.frame.size.height = 0
            createCategoryButton.isHidden = true
        case .regular:
            title = DetailTableConstants.regularTitle
            tableSectionItems = ["Категория", "Расписание"]
            if let currentDate = currentDate {
                selectedWeekDays = [WeekDay(date: currentDate)]
            }
            daysCompletedLabel.frame.size.height = 0
            createCategoryButton.isHidden = true
        case .edit(let tracker, let category, let completedTimes):
            self.selectedCategory = category
            self.tracker = tracker
            
            title = DetailTableConstants.trackerDetailTitle
            if tracker.isRegular {
                tableSectionItems = ["Категория", "Расписание"]
                selectedWeekDays = tracker.schedule
            } else {
                tableSectionItems = ["Категория"]
            }
            selectedWeekDays = tracker.schedule
            selectedEmoji = tracker.emoji
            selectedColor = tracker.color
            
            tableView.tableHeaderView = daysCompletedLabel
            daysCompletedLabel.frame.size.height = 70
            createCategoryButton.isHidden = true
            
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
            
        case .categories(let category):
            self.selectedCategory = category
            tableView.register(TitleCell.self, forCellReuseIdentifier: TitleCell.reuseIdentifier)
            title = DetailTableConstants.categoriesTitle
            showPlaceholderIfNeeded()
            daysCompletedLabel.frame.size.height = 0
            createCategoryButton.isHidden = false
            createCategoryButton.setTitle("Добавить категорию", for: .normal)
        case .categoryDetail:
            title = "Новая категория"
            title = "Редактирование категории"
            tableView.register(TitleCell.self, forCellReuseIdentifier: TitleCell.reuseIdentifier)
            daysCompletedLabel.frame.size.height = 0
            createCategoryButton.isHidden = false
            createCategoryButton.setTitle("Готово", for: .normal)
        case .schedule(let tracker):
            self.tracker = tracker
            title = "Расписание"
            selectedWeekDays = tracker.schedule
            
            daysCompletedLabel.frame.size.height = 0
            createCategoryButton.isHidden = false
            createCategoryButton.setTitle("Готово", for: .normal)
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
    
    // MARK: - Register cells
    private func registerCells() {
        switch tableType {
        case .special, .regular:
            tableView.register(TitleCell.self, forCellReuseIdentifier: TitleCell.reuseIdentifier)
            tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.reuseIdentifier)
            tableView.register(ButtonsTableViewCell.self, forCellReuseIdentifier: ButtonsTableViewCell.reuseIdentifier)
            tableView.register(EmojisTableViewCell.self, forCellReuseIdentifier: EmojisTableViewCell.reuseIdentifier)
            tableView.register(ColorsTableViewCell.self, forCellReuseIdentifier: ColorsTableViewCell.reuseIdentifier)
        case .edit:
            tableView.register(SectionHeaderTableViewCell.self, forCellReuseIdentifier: SectionHeaderTableViewCell.reuseIdentifier)
            tableView.register(TitleCell.self, forCellReuseIdentifier: TitleCell.reuseIdentifier)
            tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.reuseIdentifier)
            tableView.register(ButtonsTableViewCell.self, forCellReuseIdentifier: ButtonsTableViewCell.reuseIdentifier)
            tableView.register(EmojisTableViewCell.self, forCellReuseIdentifier: EmojisTableViewCell.reuseIdentifier)
            tableView.register(ColorsTableViewCell.self, forCellReuseIdentifier: ColorsTableViewCell.reuseIdentifier)
        case .categories:
            tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.reuseIdentifier)
        case .categoryDetail, .schedule:
            tableView.register(TitleCell.self, forCellReuseIdentifier: TitleCell.reuseIdentifier)
        }
    }
    
    // MARK: - Navigation
    private func showCategoryDetail(indexPath: IndexPath) {
        
    }
    
    private func deleteCategory(at indexPath: IndexPath) {
        
    }
    
    // MARK: - Storage
//    private func loadCategories() {
//        trackerStorage.loadCategories { [weak self] in
//            guard let self else { return }
//            self.categories = self.trackerStorage.categories
//        }
//    }
//    
//    private func saveCategories() {
//        trackerStorage.categories = categories
//        trackerStorage.saveCategories()
//    }
    
    // MARK: - Placeholder
    private func showPlaceholderIfNeeded() {
        if let categories, categories.count == 0 {
            placeholderStackView.isHidden = false
        } else {
            placeholderStackView.isHidden = true
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch tableType {
        case .special, .regular, .edit:
            return 5
        case .categories, .categoryDetail, .schedule:
            return 1
        }
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
        case .categories:
            guard let categories else { return 0 }
            return categories.count
        case .categoryDetail:
            return 1
        case .schedule:
            return weekDays.count
        }
    }

    // MARK: - CellForRow
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableType {
            case .special, .regular, .edit:
            switch indexPath.section {
            case 0:
                switch indexPath.row {
                case 0:
                    let cell = TitleCell()
                    cell.configure(
                        with: tracker?.title,
                        placeholder: DetailTableConstants.trackerTitelPlaceholder
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
                    tracker: tracker,
                    indexPath: indexPath,
                    cellType: .chevron,
                    selected: nil
                )
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
        case .categories:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.reuseIdentifier, for: indexPath) as? SettingsCell,
                let categories
            else {
                return UITableViewCell()
            }
            
            let cellPosition: CellPosition
            
            switch indexPath.row {
            case 0:
                if categories.count == 1 {
                    cellPosition = .single
                } else {
                    cellPosition = .first
                }
            case categories.count - 1:
                cellPosition = .last
            default:
                cellPosition = .regular
            }
            
            let categoryId = categories[indexPath.row].id
            let isSelected = categoryId == selectedCategory?.id
            
            cell.configure(
                itemTitle: categories[indexPath.row].title,
                cellPosition: cellPosition,
                category: selectedCategory,
                tracker: tracker,
                indexPath: indexPath,
                cellType: .checkmark,
                selected: isSelected
            )
            
            return cell
        case .categoryDetail:
            let cell = TitleCell()
            cell.delegate = self
            cell.configure(with: "title", placeholder: DetailTableConstants.categoryTitlePlaceholder)
            return cell
        case .schedule:
            let cell = SettingsCell()
            let cellPosition: CellPosition
            
            switch indexPath.row {
            case 0:
                if weekDays.count == 1 {
                    cellPosition = .single
                } else {
                    cellPosition = .first
                }
            case weekDays.count - 1:
                cellPosition = .last
            default:
                cellPosition = .regular
            }
            
            cell.configure(
                itemTitle: weekDays[indexPath.row].localizedName,
                cellPosition: cellPosition,
                category: selectedCategory,
                tracker: tracker,
                indexPath: indexPath,
                cellType: .switch,
                selected: nil
            )
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch tableType {
        case .special, .regular, .edit:
            switch section {
            case 2, 3:
                return sectionHeaders[section]
            default:
                return nil
            }
        case .categories, .categoryDetail, .schedule:
            return nil
        }
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableType {
        case .special, .regular, .edit:
            if indexPath.section == 1 {
                switch indexPath.row {
                case 0:
                    guard
                        let category = selectedCategory,
                        let categories
                    else {
                        return
                    }
                    let navigationController = UINavigationController(
                        rootViewController: DetailTableViewController(
                            tableType: .categories(category), categories: categories, currentDate: nil
                        )
                    )
                    navigationController.modalPresentationStyle = .pageSheet
                    present(navigationController, animated: true)
                case 1:
                    guard let tracker = tracker else { return }
                    let navigationController = UINavigationController(rootViewController: DetailTableViewController(
                        tableType: .schedule(tracker), categories: categories, currentDate: currentDate))
                    navigationController.modalPresentationStyle = .pageSheet
                    present(navigationController, animated: true)
                default:
                    break
                }
            }
        case .categories:
            break
        case .categoryDetail:
            break
        case .schedule:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableType {
        case .special, .regular, .edit:
            switch indexPath.section {
            case 0:
                switch indexPath.row {
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
        case .categories, .schedule:
            return 75
        case .categoryDetail:
            switch indexPath.section {
            case 0:
                switch indexPath.row {
                case 1:
                    return 38
                default:
                    return 75
                }
            default:
                return 75
            }
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
            cell.configure(with: sectionHeaders[section - 2])
            return cell
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        switch tableType {
        case .categories:
            return UIContextMenuConfiguration(actionProvider: { actions in
                return UIMenu(children: [
                    UIAction(title: "Редактировать")
                    { [weak self] _ in
                        self?.showCategoryDetail(indexPath: indexPath)
                    },
                    
                    UIAction(title: "Удалить", attributes: .destructive)
                    { [weak self] _ in
                        self?.deleteCategory(at: indexPath)
                    },
                ])
            })
        case .categoryDetail, .schedule, .special, .regular, .edit:
            return nil
        }
    }
    
    // MARK: - Actions
    @objc
    private func switchToAddCategoryViewController() {
        
    }
    
    // MARK: - Constraints
    private func addPlaceholder() {
        view.addSubview(placeholderStackView)
        placeholderStackView.addArrangedSubview(placeholderImageView)
        placeholderStackView.addArrangedSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            placeholderStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func addCreateCategoryButton() {
        view.addSubview(createCategoryButton)
        
        NSLayoutConstraint.activate([
            createCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            createCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32)
        ])
    }
}

// MARK: - TitleCellDelegate
extension DetailTableViewController: TitleCellDelegate {
    func titleChanged(title: String?) {
        guard let title else { return }
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
            titleSectionItems.append(errorMessage)
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
    let navigationController = UINavigationController(rootViewController: DetailTableViewController(tableType: .special, categories: nil, currentDate: nil))
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}

@available(iOS 17, *)
#Preview("Regular") {
    let navigationController = UINavigationController(rootViewController: DetailTableViewController(tableType: .regular, categories: nil, currentDate: nil))
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}

@available(iOS 17, *)
#Preview("Edit") {
    let selectedCategory = TrackerCategory(id: UUID(), title: "Foo", trackers: [
        Tracker(
            id: UUID(),
            title: "Lorem ipsum dolor sit amet, consetetur",
            color: Constants.selectionColors[4],
            emoji: Constants.emojis[0],
            schedule: [WeekDay.tuesday, WeekDay.friday],
            isRegular: true
        )
    ])
    let categories: [TrackerCategory] = [
        selectedCategory,
        TrackerCategory(id: UUID(), title: "Baz", trackers: []),
        TrackerCategory(id: UUID(), title: "Bar", trackers: []),
    ]
    
    let tracker = categories[0].trackers![0]
    let navigationController = UINavigationController(rootViewController: DetailTableViewController(tableType: .edit(tracker, selectedCategory, 2), categories: nil, currentDate: nil))
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}

@available(iOS 17, *)
#Preview("Categories") {
    let selectedCategory = TrackerCategory(id: UUID(), title: "Quux", trackers: [])
    let categories: [TrackerCategory] = [
        selectedCategory,
        TrackerCategory(id: UUID(), title: "Foo", trackers: []),
        TrackerCategory(id: UUID(), title: "Baz", trackers: []),
        TrackerCategory(id: UUID(), title: "Bar", trackers: []),
    ]
    let navigationController = UINavigationController(
        rootViewController: DetailTableViewController(
            tableType: .categories(selectedCategory),
            categories: categories,
            currentDate: nil
        )
    )
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}

@available(iOS 17, *)
#Preview("Category Detail") {
    let selectedCategory = TrackerCategory(id: UUID(), title: "Quux", trackers: [])
    let categories: [TrackerCategory] = [
        selectedCategory,
        TrackerCategory(id: UUID(), title: "Foo", trackers: []),
        TrackerCategory(id: UUID(), title: "Baz", trackers: []),
        TrackerCategory(id: UUID(), title: "Bar", trackers: []),
    ]
    let navigationController = UINavigationController(
        rootViewController: DetailTableViewController(
            tableType: .categoryDetail,
            categories: categories,
            currentDate: nil
        )
    )
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}
#endif
