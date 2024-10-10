//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 20.09.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Properties
    private var categories: [TrackerCategory] = []
    private var trackerStorage = TrackerStorage()
    private var currentDate: Date?
    private var filteredCategories: [TrackerCategory]?
    
    /// трекеры, которые были «выполнены» в выбранную дату
    /// Чтобы не выполнять линейный поиск по массиву, используем Set, в котором хранятся id выполненных трекеров;
    private var completedTrackers: Set<TrackerRecord> = []
    
    private let params = GeometricParams(
        cellCount: 2,
        topInset: 8,
        bottomInset: 16,
        leftInset: 16,
        rightInset: 16,
        cellSpacing: 9,
        cellHeight: 132,
        lineSpacing: 16,
        headerHeight: 18
    )
    
    // MARK: - UI Components
    private lazy var addButton: UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.image = UIImage(systemName: "plus")
        view.tintColor = .ypBlack
        view.accessibilityIdentifier = "Add Button"
        view.target = self
        view.action = #selector(didTapAddButton)
        
        return view
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let view = UIDatePicker()
        view.preferredDatePickerStyle = .compact
        view.datePickerMode = .date
        view.locale = Locale(identifier: "ru_CH")
        view.addTarget(self, action: #selector(didSelectDate(_:)), for: .valueChanged)
        
        return view
    }()
    
    private lazy var placeholderStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [placeholderImageView, placeholderLabel])
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let view = UIImageView()
        view.image = .icDizzy
        
        return view
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let view = UILabel()
        view.text = "Что будем отслеживать?"
        view.font = .systemFont(ofSize: 12, weight: .medium)
        
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(TrackerCell.self,
                      forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        view.register(TrackerHeaderReusableView.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier: TrackerHeaderReusableView.reuseIdentifier)
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.allowsMultipleSelection = false
        view.dataSource = self
        view.delegate = self
        
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Debug
        addMockData()
        
        loadCategories()
        
        // Debug: clear tracker records
        completedTrackers = []
        saveCompletedTrackers()
        
        loadCompletedTrackers()
        
        currentDate = datePicker.date.truncated
        print("Debug", "Current date", currentDate ?? "nil", separator: " -- ")
        
        filteredCategories = filterCategories(with: currentDate)
        
        setupUI()
        showPlaceholderIfNeeded()
    }
    
    /// возвращает отфильтрованный массив категорий содержащий только трекеры на выбранную дату
    private func filterCategories(with date: Date?) -> [TrackerCategory]? {
        guard let date = date else { return nil }
        // Определяем текущий день недели
        let weekDay = WeekDay(date: date)
        
        // Фильтруем категории
        return categories.compactMap { category in
            // Фильтруем трекеры, которые имеют расписание на текущий день
            let filteredTrackers = category.trackers?.filter { tracker in
                tracker.schedule?.contains(weekDay) == true
            }
            
            // Если есть хотя бы один трекер с расписанием на текущий день, возвращаем новую категорию
            if let filteredTrackers = filteredTrackers, !filteredTrackers.isEmpty {
                return TrackerCategory(title: category.title, trackers: filteredTrackers)
            } else {
                return nil
            }
        }
    }
    
    // MARK: - Storage
    private func loadCategories() {
        trackerStorage.loadCategories { [weak self] in
            guard let self else { return }
            self.categories = self.trackerStorage.categories
            // Debug
            if self.categories.isEmpty {
                self.addMockData()
            }
        }
    }
    
    private func loadCompletedTrackers() {
        trackerStorage.loadCompletedTrackers { [weak self] in
            guard let self else { return }
            self.completedTrackers = self.trackerStorage.completedTrackers
        }
    }
    
    private func saveCategories() {
        trackerStorage.categories = categories
        trackerStorage.saveCategories()
    }
    
    private func saveCompletedTrackers() {
        trackerStorage.completedTrackers = completedTrackers
        trackerStorage.saveCompletedTrackers()
    }
    
    private func addMockData() {
        trackerStorage.categories = Mock.categories
        trackerStorage.saveCategories()
    }

    func setupUI() {
        title = "Трекеры"
        setupNavigationBar()
        
        addCollectionView()
        addPlaceholder()
        
        if filteredCategories != nil {
            placeholderStackView.isHidden = true
        }
    }
    
    // MARK: - UI Setup
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = UISearchController()
        navigationItem.searchController?.searchBar.placeholder = "Поиск"
        
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 95)
        ])
    }
    
    private func showPlaceholderIfNeeded() {
        guard let filteredCategories = filteredCategories else {
            placeholderStackView.isHidden = false
            return
        }
        if filteredCategories.isEmpty {
            placeholderStackView.isHidden = false
        } else {
            placeholderStackView.isHidden = true
        }
    }
    
    // MARK: - Actions
    private func showTrackerDetail(indexPath: IndexPath) {
        guard let trackers = categories[indexPath.section].trackers else { return }
        
        let tracker = trackers[indexPath.item]
        let navigationController = UINavigationController(rootViewController: TrackerDetailTableViewController(tracker: tracker, isRegular: true))
        navigationController.modalPresentationStyle = .pageSheet
        
        present(navigationController, animated: true)
    }
    
    private func deleteTracker(at indexPath: IndexPath) {
        guard let trackers = categories[indexPath.section].trackers else { return }

        let tracker = trackers[indexPath.item]
        
        categories = categories.map {
            var trackers = $0.trackers
            if let index = trackers?.firstIndex(where: { $0.id == tracker.id }) {
                trackers?.remove(at: index)
            }
            return TrackerCategory(title: $0.title, trackers: trackers)
        }

        saveCategories()
        
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [indexPath])
        }
    }
    
    @objc
    private func didTapAddButton() {
        let navigationController = UINavigationController(rootViewController: TrackerTypeViewController())
        navigationController.modalPresentationStyle = .pageSheet
        
        present(navigationController, animated: true)
    }
    
    @objc
    private func didSelectDate(_ sender: UIDatePicker) {
        currentDate = sender.date.truncated
        filteredCategories = filterCategories(with: currentDate)
        collectionView.reloadData()
        showPlaceholderIfNeeded()
        self.dismiss(animated: true)
    }
    
    // MARK: - Constraints
    private func addCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func addPlaceholder() {
        view.addSubview(placeholderStackView)
        
        NSLayoutConstraint.activate([
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let filteredCategories = filteredCategories else { return 0 }
        return filteredCategories.count
     }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let filteredCategories,
           let trackers = filteredCategories[section].trackers {
            return trackers.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerCell.reuseIdentifier,
                for: indexPath
            ) as? TrackerCell,
            let filteredCategories = filteredCategories,
            let trackers = filteredCategories[indexPath.section].trackers
        else {
            return UICollectionViewCell()
        }
        let tracker = trackers[indexPath.row]
        
        // Debug
        print(tracker)
        
        let trackerRecord = completedTrackers.first(where: {
            $0.id == tracker.id && $0.date == currentDate
        })
        // Debug
        print(trackerRecord ?? "No record")
        
        cell.delegate = self
        cell.configure(with: tracker,
                       recordModel: trackerRecord,
                       indexPath: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = TrackerHeaderReusableView.reuseIdentifier
        case UICollectionView.elementKindSectionFooter:
            id = ""
        default:
            id = ""
        }
        
        if let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? TrackerHeaderReusableView {
            guard let filteredCategories = filteredCategories else { return UICollectionReusableView() }
            let title = filteredCategories[indexPath.section].title
            view.configure(with: title)
            return view
        }
        
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableSpace = collectionView.frame.width - params.paddingWidth
        let cellWidth = availableSpace / params.cellCount
        
        return CGSize(width: cellWidth, height: params.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = UIEdgeInsets(
            top: params.topInset,
            left: params.leftInset,
            bottom: params.bottomInset,
            right: params.rightInset
        )
        
        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return params.lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int)  -> CGSize {
        
        // ofSize should be the same size of the headerView's label size:
//        return CGSize(width: collectionView.frame.size.width, height:
//        categories[section].title.heightWithConstrainedWidth(font: UIFont.systemFont(ofSize: 19, weight: .bold)))
        
        //
        let headerView = TrackerHeaderReusableView(frame: .zero)
        guard let filteredCategories = filteredCategories else { return .zero }
        headerView.configure(with: filteredCategories[section].title)
        
        return headerView.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width,
                   height: collectionView.frame.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else {
            return nil
        }
        
        let indexPath = indexPaths[0]
        
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: "Закрепить")
                { /*[weak self]*/ _ in },
                
                UIAction(title: "Редактировать")
                { [weak self] _ in
                    self?.showTrackerDetail(indexPath: indexPath)
                },
                
                UIAction(title: "Удалить", attributes: .destructive)
                { [weak self] _ in
                    self?.deleteTracker(at: indexPath)
                },
            ])
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else { return nil }
        let selectedView = cell.configureSelectedView()
        
        return UITargetedPreview(view: selectedView)
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    /// Когда пользователь нажимает на + в ячейке трекера, добавляется соответствующая запись в completedTrackers. Если пользователь убирает пометку о выполненности в ячейке трекера, элемент удаляется из массива.
    func changeTrackerState(for tracker: Tracker, at indexPath: IndexPath) {
        
        guard let currentDate = currentDate, currentDate <= Date() else { return }

        let trackerRecord = TrackerRecord(id: tracker.id, date: currentDate)
        
        var daysCounter = 0
        if let daysCompleted = tracker.daysCompleted {
            daysCounter = daysCompleted
        }
        
        var newCategories: [TrackerCategory] = []
        
        if let completedTracker = completedTrackers.first(where: { $0.date == currentDate && $0.id == tracker.id && currentDate <= Date() }) {
            completedTrackers.remove(completedTracker)
            
            // decreaseDayCount
            daysCounter -= 1
            let newTracker = Tracker(id: tracker.id, name: tracker.name, color: tracker.color, emoji: tracker.emoji, schedule: tracker.schedule, daysCompleted: daysCounter)
            
            for category in categories {
                if let trackers = category.trackers {
                    if let index = trackers.firstIndex(where: { $0.id == tracker.id }) {
                        let newTrackers = trackers.map { $0.id == tracker.id ? newTracker : $0 }
                        newCategories.insert(TrackerCategory(title: category.title, trackers: newTrackers), at: index)
                    } else {
                        newCategories.append(category)
                    }
                } else {
                    newCategories.append(category)
                }
            }
//            categories = newCategories
            
        } else {
            completedTrackers.insert(trackerRecord)

            daysCounter += 1
            let newTracker = Tracker(id: tracker.id, name: tracker.name, color: tracker.color, emoji: tracker.emoji, schedule: tracker.schedule, daysCompleted: daysCounter)
            
            // Скопировать содержимое categories в newCategories
            // Заменить tracker на newTracker
            for category in categories {
                if let trackers = category.trackers {
                    if let index = trackers.firstIndex(where: { $0.id == tracker.id }) {
                        let newTrackers = trackers.map { $0.id == tracker.id ? newTracker : $0 }
                        newCategories.insert(TrackerCategory(title: category.title, trackers: newTrackers), at: index)
                    } else {
                        newCategories.append(category)
                    }
                } else {
                    newCategories.append(category)
                }
            }
            
        }
        categories = newCategories
        filteredCategories = filterCategories(with: currentDate)
        saveCategories()
        saveCompletedTrackers()
        
        collectionView.performBatchUpdates {
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

//extension String {
//    func heightWithConstrainedWidth(font: UIFont) -> CGFloat {
//        let constraintRect = CGSize(width: UIScreen.main.bounds.width, height: CGFloat.greatestFiniteMagnitude)
//        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
//
//        return boundingBox.height
//    }
//}

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        updateTrackersForCurrentDate(searchedText: searchBar.text)
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview() {
    TabBarController()
}
#endif
