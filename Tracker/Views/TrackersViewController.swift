//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 20.09.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Properties
    private var trackerStore: TrackerStoreProtocol
    private let scheduleStore: ScheduleStoreProtocol
    private let recordStore: RecordStoreProtocol
    private let categoryStore: CategoryStoreProtocol
    private let analyticsService: AnalyticsServiceProtocol

    private var selectedFilter: Filter = UserDefaults.standard.loadFilter()
    private var placeholderState: PlaceholderState = .trackers

    private let params = Constants.trackersCollectionViewGeometricParam

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

    lazy var datePicker: UIDatePicker = {
        let view = UIDatePicker()
        view.preferredDatePickerStyle = .compact
        view.datePickerMode = .date
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
        view.backgroundColor = .clear
        view.alwaysBounceVertical = true
        view.allowsMultipleSelection = false
        view.dataSource = self
        view.delegate = self

        return view
    }()

    // MARK: - Init
    init(
        trackerStore: TrackerStoreProtocol,
        scheduleStore: ScheduleStoreProtocol,
        recordStore: RecordStoreProtocol,
        categoryStore: CategoryStoreProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.trackerStore = trackerStore
        self.scheduleStore = scheduleStore
        self.recordStore = recordStore
        self.categoryStore = categoryStore
        self.analyticsService = analyticsService

        super.init(nibName: nil, bundle: nil)
        self.trackerStore.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        updateStore()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        analyticsService.report(event: .open, screen: .main)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        analyticsService.report(event: .close, screen: .main)
    }

    private func updateStore(with searchText: String? = nil) {
        do {
            if let searchText {
                try trackerStore.updateFetchRequest(
                    with: searchText,
                    for: datePicker.date.truncated
                )
            } else {
                try trackerStore.updateFetchRequest(
                    with: selectedFilter,
                    for: datePicker.date.truncated
                )
            }
        } catch {
            showStoreErrorAlert(error.localizedDescription)
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
        view.backgroundColor = .ypWhite
        setupNavigationBar()
        addCollectionView()
        addFiltersButton()
        addPlaceholder()

        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        collectionView.scrollIndicatorInsets = collectionView.contentInset
    }

    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypWhite
        appearance.shadowImage = UIImage()
        appearance.backgroundImage = UIImage()
        appearance.backgroundEffect = .none
        appearance.shadowColor = .clear
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.ypBlack]

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance

        navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.hidesSearchBarWhenScrolling = false

        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchController

        searchController.hidesNavigationBarDuringPresentation = false

        let searchTextField = searchController.searchBar.searchTextField
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("placeholderSearchTrackers", comment: ""),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.ypGray]
        )

        if let leftView = searchTextField.leftView as? UIImageView {
            leftView.tintColor = UIColor.ypGray
        }

        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 100),
            datePicker.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    private func updateCounterTitle(for trackerId: UUID) throws -> String {
        do {
            let completedCount = try recordStore.fetchNumberOfRecords(for: trackerId)
            let localizedFormatString = NSLocalizedString("trackers.daysCompleted", comment: "")

            return String(format: localizedFormatString, completedCount)
        } catch {
            throw error
        }
    }

    // MARK: - Show Tracker Detail
    private func showTrackerDetail(trackerUI: TrackerUI, categoryUI: CategoryUI) {
        let counterTitle: String

        do {
            counterTitle = try updateCounterTitle(for: trackerUI.id)
        } catch {
            showStoreErrorAlert(error.localizedDescription)
            return
        }

        let viewController = TrackerTableViewController(
            tableType: .edit(trackerUI, categoryUI, counterTitle),
            categoryStore: categoryStore
        )
        viewController.delegate = self
        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        navigationController.modalPresentationStyle = .pageSheet

        present(navigationController, animated: true)
    }

    // MARK: - Delete Tracker
    private func deleteTracker(_ trackerUI: TrackerUI) {
        do {
            try trackerStore.deleteTracker(trackerUI)
        } catch {
            showStoreErrorAlert("TrackerStore")
        }

        placeholderState = .trackers
    }

    // MARK: - Update Tracker
    private func updateTracker(trackerUI: TrackerUI, categoryUI: CategoryUI) {
        do {
            try trackerStore.saveTracker(from: trackerUI, categoryUI: categoryUI)
        } catch {
            showStoreErrorAlert(error.localizedDescription)
        }
    }

    private func fetchRecord(for trackerUI: TrackerUI) -> RecordUI? {
        do {
            return try recordStore.fetchRecord(for: trackerUI, date: datePicker.date.truncated)
        } catch {
            showStoreErrorAlert(error.localizedDescription)
            return nil
        }
    }

    // MARK: - Alerts
    func showDeleteTrackerAlert(for tracker: TrackerUI) {
        let model = AlertModel(
            title: nil,
            message: NSLocalizedString("alertMessageDeleteTracker", comment: ""),
            buttons: [.deleteButton, .cancelButton],
            identifier: "Delete Tracker Alert",
            completion: { [weak self] in
                self?.deleteTracker(tracker)
            }
        )

        AlertPresenter.showAlert(on: self, model: model)
    }

    func showStoreErrorAlert(_ message: String) {
        let model = AlertModel(
            title: NSLocalizedString("alertTitleStoreError", comment: ""),
            message: message,
            buttons: [.cancelButton],
            identifier: "Store Error Alert",
            completion: nil
        )

        AlertPresenter.showAlert(on: self, model: model)
    }

    // MARK: - Actions
    @objc
    private func didTapAddButton() {
        let viewController = TrackerTypeViewController(categoryStore: categoryStore,
                                                       currentDate: datePicker.date.truncated)
        viewController.delegate = self
        let navigationController = UINavigationController( rootViewController: viewController )
        navigationController.modalPresentationStyle = .pageSheet

        present(navigationController, animated: true)
        analyticsService.report(event: .click, screen: .main, item: .addTrack)
    }

    @objc
    private func didSelectDate(_ sender: UIDatePicker) {
        updateStore()
        placeholderState = .trackers

        self.dismiss(animated: true)
    }

    @objc
    private func didTapFiltersButton() {
        let viewController = FiltersViewController()
        let viewModel = FiltersViewModel(selectedFilter: selectedFilter)
        viewController.initialize(viewModel: viewModel)
        viewController.delegate = self
        let navigationController = UINavigationController( rootViewController: viewController )
        navigationController.modalPresentationStyle = .pageSheet

        present(navigationController, animated: true)
        analyticsService.report(event: .click, screen: .main, item: .filter)
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
        let numberOfSections = trackerStore.numberOfSections

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

        return numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        trackerStore.numberOfItemsInSection(section)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? TrackerCollectionViewCell
        else {
            return UICollectionViewCell()
        }

        let trackerUI = trackerStore.fetchTracker(at: indexPath)
        let trackerRecord = fetchRecord(for: trackerUI)
        let counterTitle: String

        do {
            counterTitle = try updateCounterTitle(for: trackerUI.id)
        } catch {
            showStoreErrorAlert(error.localizedDescription)
            return UICollectionViewCell()
        }

        cell.backgroundColor = .clear
        cell.delegate = self
        cell.configure(
            tracker: trackerUI,
            record: trackerRecord,
            completedTitle: counterTitle
        )

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let section = indexPath.section
        guard let title = trackerStore.sectionTitle(at: section) else { return UICollectionReusableView() }

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
        guard let categoryTitle = trackerStore.sectionTitle(at: section) else { return .zero }

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

        guard let (category, tracker) = trackerStore.fetchTrackerWithCategory(at: indexPath) else { return nil }

        var pinButtonTitle: String {
            if tracker.isPinned {
                return NSLocalizedString("buttonUnpin", comment: "")
            } else {
                return NSLocalizedString("buttonPin", comment: "")
            }
        }

        return UIContextMenuConfiguration(actionProvider: { _ in
            return UIMenu(children: [
                UIAction(title: pinButtonTitle) { [weak self] _ in
                    guard let self else {
                        print("Error: Cannot update tracker pin status")
                        return
                    }

                    let isPinned = tracker.isPinned ? false : true
                    let updatedTracker = TrackerUI(id: tracker.id,
                                                   title: tracker.title,
                                                   color: tracker.color,
                                                   emoji: tracker.emoji,
                                                   isPinned: isPinned,
                                                   schedule: tracker.schedule,
                                                   date: tracker.date)
                    self.updateTracker(trackerUI: updatedTracker, categoryUI: category)
                },
                UIAction(title: NSLocalizedString("buttonEdit", comment: "")) { [weak self] _ in
                    guard let self else {
                        print("Error: Cannot show tracker detail view")
                        return
                    }

                    self.showTrackerDetail(trackerUI: tracker, categoryUI: category)
                    self.analyticsService.report(event: .click, screen: .main, item: .edit)
                },
                UIAction(title: NSLocalizedString("buttonDelete", comment: ""),
                         attributes: .destructive) { [weak self] _ in
                             guard let self else {
                                 print("Error: Cannot show delete tracker flow")
                                 return
                             }

                             self.showDeleteTrackerAlert(for: tracker)
                             self.analyticsService.report(event: .click, screen: .main, item: .delete)
                         }
            ])
        })
    }

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfiguration configuration: UIContextMenuConfiguration,
                        highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard
            let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell
        else {
            return nil
        }

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
            datePicker.date <= Date()
        else {
            return
        }

        do {
            if let record {
                try recordStore.deleteRecord(record)
            } else {
                let newRecord = RecordUI(trackerId: tracker.id, date: datePicker.date.truncated)
                try recordStore.addRecord(newRecord)
            }
            analyticsService.report(event: .click, screen: .main, item: .track)
        } catch {
            showStoreErrorAlert(error.localizedDescription)
        }
    }
}

// MARK: - TrackerTableViewControllerDelegate
extension TrackersViewController: TrackerTableViewControllerDelegate, TrackerTypeViewControllerDelegate {
    func cancelButtonTapped() {
        dismiss(animated: true)
    }

    func saveTracker(trackerUI: TrackerUI, categoryUI: CategoryUI) {
        placeholderState = .trackers
        updateTracker(trackerUI: trackerUI, categoryUI: categoryUI)
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
            updateStore(with: searchText)
            placeholderState = .search
        }
    }
}

// MARK: - FiltersViewControllerDelegate
extension TrackersViewController: FiltersViewControllerDelegate {
    func didSelectFilter(filter: Filter) {
        UserDefaults.standard.saveFilter(filter)
        selectedFilter = filter

        switch selectedFilter {
        case .all:
            placeholderState = .trackers
        case .today:
            datePicker.date = Date()
            placeholderState = .search
        default:
            placeholderState = .search
        }

        updateStore()
        dismiss(animated: true)
    }
}

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate(_ updates: [TrackerStoreUpdate]) {
        var movedToIndexPaths = [IndexPath]()

        if updates.isEmpty {
            collectionView.reloadData()
        } else {
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
                movedToIndexPaths.removeAll()
            })
        }
    }
}
