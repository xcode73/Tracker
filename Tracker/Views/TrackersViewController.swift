//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 20.09.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Properties
    private var placeholderState: PlaceholderState = .trackers
    private let dataStore = Constants.appDelegate().trackerDataStore

    private var trackerStore: TrackerStoreProtocol?

    private lazy var scheduleStore: ScheduleStoreProtocol? = {
        do {
            try scheduleStore = ScheduleStore(dataStore: dataStore)
            return scheduleStore
        } catch {
            placeholderState = .search
            showStoreErrorAlert()
            return nil
        }
    }()

    private lazy var recordStore: TrackerRecordStoreProtocol? = {
        do {
            try recordStore = TrackerRecordStore(dataStore: dataStore)
            return recordStore
        } catch {
            placeholderState = .search
            showStoreErrorAlert()
            return nil
        }
    }()

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

    private enum PlaceholderState {
        case search
        case trackers
    }

    // MARK: - UI Components
    private lazy var addButton: UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.image = Icons.plus
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

    private lazy var searchController: UISearchController = {
        let view = UISearchController(searchResultsController: nil)
        view.obscuresBackgroundDuringPresentation = false
        view.searchResultsUpdater = self
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
        return view
    }()

    private lazy var placeholderLabel: UILabel = {
        let view = UILabel()
        view.font = Fonts.ypMedium12
        return view
    }()

    private lazy var filtersButton: UIButton = {
        let view = UIButton()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = .ypBlue
        view.titleLabel?.font = Fonts.ypMedium16
        view.setTitleColor(.white, for: .normal)
        view.addTarget(self, action: #selector(didTapFiltersButton), for: .touchUpInside)
        view.setTitle(NSLocalizedString("buttonFilters", comment: ""), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(TrackerCollectionViewCell.self,
                      forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier)
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
        updateStore()
    }

    // MARK: - Setup Store
    func updateStore(
        searchText: String? = nil
    ) {
        do {
            try trackerStore = TrackerStore(
                dataStore: dataStore,
                delegate: self,
                date: datePicker.date,
                selectedFilter: UserDefaults.standard.loadFilter(),
                searchText: searchText
            )
        } catch {
            showStoreErrorAlert()
        }
    }

    // MARK: - Update View
    private func updatePlaceholderState(placeholderState: PlaceholderState) {
        switch placeholderState {
        case .search:
            placeholderImageView.image = .icSearch
            placeholderLabel.text = NSLocalizedString("placeholderSearch", comment: "")
        case .trackers:
            placeholderImageView.image = .icDizzy
            placeholderLabel.text = NSLocalizedString("placeholderTrackers", comment: "")
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        setupNavigationBar()
        addCollectionView()
        addFiltersButton()
        addPlaceholder()
    }

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchController

        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 95)
        ])
    }

    private func updateCounterTitle(for trackerId: UUID) -> String {
        let completedCount = recordStore?.recordsCount(for: trackerId) ?? 0
        let localizedFormatString = NSLocalizedString("trackers.daysCompleted", comment: "")

        return String(format: localizedFormatString, completedCount)
    }

    // MARK: - Show Tracker Detail
    private func showTrackerDetail(indexPath: IndexPath) {
        guard let trackerDetail = trackerStore?.trackerObject(at: indexPath) else { return }

        let schedule = scheduleStore?.getSchedule(for: trackerDetail)
        let tracker = TrackerUI(id: trackerDetail.id,
                              categoryTitle: trackerDetail.categoryTitle,
                              title: trackerDetail.title,
                              color: trackerDetail.color,
                              emoji: trackerDetail.emoji,
                              schedule: schedule,
                              date: trackerDetail.date)

        let counterTitle = updateCounterTitle(for: tracker.id)
        let viewController = TrackerTableViewController(tableType: .edit(tracker, counterTitle),
                                            trackerDataStore: dataStore,
                                            indexPath: indexPath)
        viewController.delegate = self
        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        navigationController.modalPresentationStyle = .pageSheet

        present(navigationController, animated: true)
    }

    // MARK: - Delete Tracker
    private func deleteTracker(at indexPaths: [IndexPath]) {
        let indexPath = indexPaths[0]
        try? trackerStore?.deleteTracker(at: indexPath)
        placeholderState = .trackers
    }

    // MARK: - Alerts
    func showDeleteTrackerAlert(for indexPaths: [IndexPath]) {
        let model = AlertModel(
            title: nil,
            message: NSLocalizedString("alertMessageDeleteTracker", comment: ""),
            buttons: [.deleteButton, .cancelButton],
            identifier: "Delete Tracker Alert",
            completion: { [weak self] in
                guard let self else { return }

                self.deleteTracker(at: indexPaths)
            }
        )

        AlertPresenter.showAlert(on: self, model: model)
    }

    func showStoreErrorAlert() {
        let model = AlertModel(
            title: NSLocalizedString("alertTitleStoreError", comment: ""),
            message: NSLocalizedString("alertMessageStoreError", comment: ""),
            buttons: [.cancelButton],
            identifier: "Tracker Store Error Alert",
            completion: nil
        )

        AlertPresenter.showAlert(on: self, model: model)
    }

    // MARK: - Actions
    @objc
    private func didTapAddButton() {
        let viewController = TrackerTypeViewController(trackerDataStore: dataStore,
                                           currentDate: datePicker.date)
        viewController.delegate = self
        let navigationController = UINavigationController( rootViewController: viewController )
        navigationController.modalPresentationStyle = .pageSheet

        present(navigationController, animated: true)
    }

    @objc
    private func didSelectDate(_ sender: UIDatePicker) {
        updateStore()
        placeholderState = .trackers
        collectionView.reloadData()

        self.dismiss(animated: true)
    }

    @objc
    private func didTapFiltersButton() {
        let viewController = FiltersViewController()
        let viewModel = FiltersViewModel(selectedFilter: UserDefaults.standard.loadFilter())
        viewController.initialize(viewModel: viewModel)
        viewController.delegate = self
        let navigationController = UINavigationController( rootViewController: viewController )
        navigationController.modalPresentationStyle = .pageSheet

        present(navigationController, animated: true)
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

    private func addFiltersButton() {
        view.addSubview(filtersButton)

        NSLayoutConstraint.activate([
            filtersButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let numberOfSections = trackerStore?.numberOfSections ?? 0

        updatePlaceholderState(placeholderState: placeholderState)

        if numberOfSections == 0 {
            placeholderStackView.isHidden = false

            if placeholderState == .trackers {
                filtersButton.isHidden = true
            }
        } else {
            placeholderStackView.isHidden = true
            filtersButton.isHidden = false
        }

        return trackerStore?.numberOfSections ?? 0
     }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        trackerStore?.numberOfItemsInSection(section) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? TrackerCollectionViewCell,
            let tracker = trackerStore?.trackerObject(at: indexPath),
            let truncatedDate = datePicker.date.truncated
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
        guard let title = trackerStore?.sectionTitle(at: section) else { return UICollectionReusableView() }

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

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return params.lineSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerView = TrackerHeaderReusableView(frame: .zero)
        guard let categoryTitle = trackerStore?.sectionTitle(at: section) else { return .zero }

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

        return UIContextMenuConfiguration(actionProvider: { _ in
            return UIMenu(children: [
                UIAction(title: NSLocalizedString("buttonPin", comment: "")) { /*[weak self]*/ _ in
                    // TODO: implement
                },
                UIAction(title: NSLocalizedString("buttonEdit", comment: "")) { [weak self] _ in
                    self?.showTrackerDetail(indexPath: indexPath)
                },
                UIAction(title: NSLocalizedString("buttonDelete", comment: ""),
                         attributes: .destructive) { [weak self] _ in
                    self?.showDeleteTrackerAlert(for: indexPaths)
                }
            ])
        })
    }

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfiguration configuration: UIContextMenuConfiguration,
                        highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else { return nil }
        let selectedView = cell.configureSelectedView()

        return UITargetedPreview(view: selectedView)
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func changeTrackerState(
        tracker: TrackerUI?,
        record: RecordUI?
    ) {
        guard
            let tracker = tracker,
            let truncatedDate = datePicker.date.truncated,
            datePicker.date <= Date()
        else {
            return
        }

        if let record {
            try? recordStore?.deleteRecord(record)
        } else {
            let newRecord = RecordUI(trackerId: tracker.id, date: truncatedDate)
            try? recordStore?.addRecord(newRecord)
        }
    }
}

// MARK: - TrackerTableViewControllerDelegate
extension TrackersViewController: TrackerTableViewControllerDelegate, TrackerTypeViewControllerDelegate {
    func cancelButtonTapped() {
        try? trackerStore?.refresh()
        dismiss(animated: true)
    }

    func createTracker(tracker: TrackerUI) {
        try? trackerStore?.addTracker(tracker)
        if tracker.schedule != nil {
            try? scheduleStore?.addSchedule(to: tracker)
        }
        placeholderState = .trackers
        dismiss(animated: true)
    }

    func updateTracker(tracker: TrackerUI, at indexPath: IndexPath) {
        try? trackerStore?.refresh()
        try? trackerStore?.updateTracker(tracker: tracker, at: indexPath)
        if tracker.schedule != nil {
            try? scheduleStore?.deleteSchedule(for: tracker)
            try? scheduleStore?.addSchedule(to: tracker)
        }

        collectionView.reloadData()
        dismiss(animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }

        if searchText.isEmpty {
            updateStore()
            placeholderState = .trackers
        } else {
            updateStore(searchText: searchText)
            placeholderState = .search
        }

        collectionView.reloadData()
    }
}

// MARK: - FiltersViewControllerDelegate
extension TrackersViewController: FiltersViewControllerDelegate {
    func didSelectFilter(filter: Filter) {
        UserDefaults.standard.saveFilter(filter)

        switch filter {
        case .all:
            placeholderState = .trackers
        case .today:
            datePicker.date = Date()
            placeholderState = .search
        default:
            placeholderState = .search
        }

        updateStore()
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
        }, completion: { _ in
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
