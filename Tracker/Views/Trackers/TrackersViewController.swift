//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 20.09.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Properties
    private let trackerDataStore = (UIApplication.shared.delegate as! AppDelegate).trackerDataStore
    
    private var trackersStore: TrackerStoreProtocol?
    
    private lazy var scheduleStore: ScheduleStoreProtocol? = {
        do {
            try scheduleStore = ScheduleStore(dataStore: trackerDataStore)
            return scheduleStore
        } catch {
            showError(message: "Данные недоступны.")
            return nil
        }
    }()
    
    private lazy var recordStore: TrackerRecordStoreProtocol? = {
        do {
            try recordStore = TrackerRecordStore(dataStore: trackerDataStore)
            return recordStore
        } catch {
            showError(message: "Данные недоступны.")
            return nil
        }
    }()
    
    private var currentDate: Date = Date() {
        didSet {
            trackersStore = setupStore(date: currentDate)
        }
    }
    
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
    
    private enum LocalConst {
        static let placeholderTitle = "Что будем отслеживать?"
        static let deleteTrackerAlertMessage = "Уверены что хотите удалить трекер?"
        static let deleteTrackerAlertIdentifier = "Delete Tracker Alert"
    }
    
    // MARK: - UI Components
    private lazy var addButton: UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.image = UIImage(systemName: "plus")
        view.tintColor = .ypBlack
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
        view.text = LocalConst.placeholderTitle
        view.font = Constants.Fonts.ypMedium12
        
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
        view.allowsMultipleSelection = false
        view.dataSource = self
        view.delegate = self
        
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        trackersStore = setupStore(date: currentDate)
    }
    
    func setupStore(date: Date) -> TrackerStoreProtocol? {
        do {
            try trackersStore = TrackerStore(
                dataStore: trackerDataStore,
                delegate: self,
                date: currentDate
            )
            return trackersStore
        } catch {
            showError(message: "Данные недоступны.")
            return nil
        }
    }
    
    // MARK: - UI Setup
    func setupUI() {
        setupNavigationBar()
        addCollectionView()
        addPlaceholder()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = UISearchController()
        
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 95)
        ])
    }
    
    private func updateCounterTitle(for trackerId: UUID) -> String {
        let completedCount = recordStore?.recordsCount(for: trackerId) ?? 0
        
        var title: String
        let lastDigit = completedCount % 10
        
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
        
        return "\(completedCount) " + title
    }
    
    // MARK: - Delete Alert
    func showDeleteTrackerAlert(for indexPaths: [IndexPath]) {
        let model = AlertModel(
            title: nil,
            message: LocalConst.deleteTrackerAlertMessage,
            buttons: [.deleteButton, .cancelButton],
            identifier: LocalConst.deleteTrackerAlertIdentifier,
            completion: { [weak self] in
                guard let self else { return }
                
                self.deleteTracker(at: indexPaths)
            }
        )
        
        AlertPresenter.showAlert(on: self, model: model)
    }
    
    // MARK: - Show Tracker Detail
    private func showTrackerDetail(indexPath: IndexPath) {
        guard let trackerDetail = trackersStore?.trackerObject(at: indexPath) else { return }
        
        let schedule = scheduleStore?.getSchedule(for: trackerDetail)
        let tracker = Tracker(id: trackerDetail.id,
                              categoryTitle: trackerDetail.categoryTitle,
                              title: trackerDetail.title,
                              color: trackerDetail.color,
                              emoji: trackerDetail.emoji,
                              schedule: schedule,
                              date: trackerDetail.date)
        
        let counterTitle = updateCounterTitle(for: tracker.id)
        let vc = TrackerTableViewController(tableType: .edit(tracker, counterTitle),
                                            trackerDataStore: trackerDataStore,
                                            indexPath: indexPath)
        vc.delegate = self
        let navigationController = UINavigationController(
            rootViewController: vc
        )
        navigationController.modalPresentationStyle = .pageSheet
        
        present(navigationController, animated: true)
    }
    
    // MARK: - Delete Tracker
    private func deleteTracker(at indexPaths: [IndexPath]) {
        let indexPath = indexPaths[0]
        try? trackersStore?.deleteTracker(at: indexPath)
    }
    
    // MARK: Data Provider alert
    func showError(message: String) {
        let model = AlertModel(
            title: "Ошибка!",
            message: message,
            buttons: [.cancelButton],
            identifier: "Tracker Store Error Alert",
            completion: nil
        )
        
        AlertPresenter.showAlert(on: self, model: model)
    }
    
    // MARK: - Actions
    @objc
    private func didTapAddButton() {
        let vc = TrackerTypeViewController(trackerDataStore: trackerDataStore,
                                           currentDate: currentDate)
        vc.delegate = self
        let navigationController = UINavigationController( rootViewController: vc )
        navigationController.modalPresentationStyle = .pageSheet
        
        present(navigationController, animated: true)
    }
    
    @objc
    private func didSelectDate(_ sender: UIDatePicker) {
        currentDate = sender.date
        trackersStore = setupStore(date: currentDate)
        collectionView.reloadData()
        
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
        let numberOfSections = trackersStore?.numberOfSections
        
        if numberOfSections == nil || numberOfSections == 0 {
            placeholderStackView.isHidden = false
        } else {
            placeholderStackView.isHidden = true
        }
        
        return numberOfSections ?? 0
     }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        trackersStore?.numberOfItemsInSection(section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerCell.reuseIdentifier,
                for: indexPath
            ) as? TrackerCell,
            let tracker = trackersStore?.trackerObject(at: indexPath),
            let truncatedDate = currentDate.truncated
        else {
            return UICollectionViewCell()
        }
        
        let trackerRecord = recordStore?.recordObject(for: tracker.id, date: truncatedDate)
        
        cell.delegate = self
        cell.configure(
            tracker: tracker,
            record: trackerRecord,
            completedTitle: updateCounterTitle(for: tracker.id)
        )
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let section = indexPath.section
        guard let title = trackersStore?.sectionTitle(at: section) else { return UICollectionReusableView() }
        
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = TrackerHeaderReusableView.reuseIdentifier
        case UICollectionView.elementKindSectionFooter:
            id = ""
        default:
            id = ""
        }
        
        if let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: id,
            for: indexPath
        ) as? TrackerHeaderReusableView {
            
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
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = UIEdgeInsets(
            top: params.topInset,
            left: params.leftInset,
            bottom: params.bottomInset,
            right: params.rightInset
        )
        
        return insets
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        
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
        guard let categoryTitle = trackersStore?.sectionTitle(at: section) else { return .zero }
        
        headerView.configure(with: categoryTitle)
        
        return headerView.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width,
                   height: collectionView.frame.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else { return nil }
        
        let indexPath = indexPaths[0]
        
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: Constants.ButtonTitles.pin)
                { /*[weak self]*/ _ in
                    // TODO: implement
                },
                
                UIAction(title: Constants.ButtonTitles.edit)
                { [weak self] _ in
                    self?.showTrackerDetail(indexPath: indexPath)
                },
                
                UIAction(title: Constants.ButtonTitles.delete, attributes: .destructive)
                { [weak self] _ in
                    self?.showDeleteTrackerAlert(for: indexPaths)
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
    func changeTrackerState(
        tracker: Tracker?,
        record: TrackerRecord?
    ) {
        guard
            let tracker = tracker,
            let truncatedDate = currentDate.truncated,
            currentDate <= Date()
        else {
            return
        }
        
        if let record {
            try? recordStore?.deleteRecord(record)
        } else {
            let newRecord = TrackerRecord(trackerId: tracker.id, date: truncatedDate)
            try? recordStore?.addRecord(newRecord)
        }
    }
}

// MARK: - UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        updateTrackersForCurrentDate(searchedText: searchBar.text)
    }
}

// MARK: - TrackerTableViewControllerDelegate
extension TrackersViewController: TrackerTableViewControllerDelegate, TrackerTypeViewControllerDelegate {
    func cancelButtonTapped() {
        try? trackersStore?.refresh()
        dismiss(animated: true)
    }
    
    func createTracker(tracker: Tracker) {
        try? trackersStore?.addTracker(tracker)
        if tracker.schedule != nil {
            try? scheduleStore?.addSchedule(to: tracker)
        }
        dismiss(animated: true)
    }
    
    func updateTracker(tracker: Tracker, at indexPath: IndexPath) {
        try? trackersStore?.refresh()
        try? trackersStore?.updateTracker(tracker: tracker, at: indexPath)
        if tracker.schedule != nil {
            try? scheduleStore?.deleteSchedule(for: tracker)
            try? scheduleStore?.addSchedule(to: tracker)
        }
        
        collectionView.reloadData()
        dismiss(animated: true)
    }
}

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate(_ updates: [TrackerStoreUpdate]) {
        var movedToIndexPaths = [IndexPath]()
        
        collectionView.performBatchUpdates({
            for update in updates {
                switch update {
                case let .section(sectionUpdate):
                    switch sectionUpdate {
                    case let .inserted(index):
                        collectionView.insertSections([index])
                    case let .deleted(index):
                        collectionView.deleteSections([index])
                    }
                case let .object(objectUpdate):
                    switch objectUpdate {
                    case let .inserted(at: indexPath):
                        collectionView.insertItems(at: [indexPath])
                    case let .deleted(from: indexPath):
                        collectionView.deleteItems(at: [indexPath])
                    case let .updated(at: indexPath):
                        collectionView.reloadItems(at: [indexPath])
                    case let .moved(from: source, to: target):
                        collectionView.moveItem(at: source, to: target)
                        movedToIndexPaths.append(target)
                    }
                }
            }
        }, completion: { done in
            self.collectionView.reloadItems(at: movedToIndexPaths)
        })
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview() {
    TabBarController()
}
#endif
