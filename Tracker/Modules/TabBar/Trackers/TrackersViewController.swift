//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 20.09.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Properties
    private var categories: [TrackerCategory] = Constants.mockCategories
    
    private var currentDate: Date?
    
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
        
        let currentDate = Date()
        let calendar = Calendar.current
        let minDate = currentDate
        let maxDate = calendar.date(byAdding: .year, value: 1, to: currentDate)
        view.minimumDate = minDate
        view.maximumDate = maxDate
        
        view.addTarget(self, action: #selector(didSelectDate(_:)), for: .valueChanged)
        
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
        view.text = "Что будем отслеживать?"
        view.font = .systemFont(ofSize: 12, weight: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        
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
        view.dataSource = self
        view.delegate = self
        
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func filterCategories(with date: Date) -> [TrackerCategory] {
        let weekDay = WeekDay(date: date)
        let filteredCategories = categories.filter {
            $0.trackers.contains(
                where: {
                    $0.schedule?.contains(weekDay) ?? false
                }
            )
        }
        
        return filteredCategories
    }
    
    private func showTrackerTypeViewController() {
        let navigationController = UINavigationController(rootViewController: TrackerTypeViewController())
        navigationController.modalPresentationStyle = .pageSheet
        
        present(navigationController, animated: true)
    }
    
    // MARK: - Constraints
    func setupUI() {
        title = "Трекеры"
        setupNavigationBar()
        if categories.isEmpty {
            addPlaceholder()
        } else {
            addCollectionView()
        }
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = UISearchController()
        navigationItem.searchController?.searchBar.placeholder = "Поиск"
        
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 79)
        ])
    }
    
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
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 16)
        ])
    }
        
    // MARK: - Actions
    @objc
    private func didTapAddButton() {
        showTrackerTypeViewController()
    }
    
    @objc
    private func didSelectDate(_ sender: UIDatePicker) {
        currentDate = sender.date
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return categories.count
     }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        cell.prepareForReuse()
        cell.configure(with: categories[indexPath.section].trackers[indexPath.row])
        
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
            let title = categories[indexPath.section].title
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
        
//        // Вью сама считает свою высоту
//        let indexPath = IndexPath(row: 0, section: section)
//        // При получении вью у коллекции происходит ошибка в рантайме
//        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
//        let size = headerView.systemLayoutSizeFitting(
//            CGSize(
//                width: collectionView.frame.width,
//                height: UIView.layoutFittingCompressedSize.height
//            ),
//            withHorizontalFittingPriority: .required,
//            verticalFittingPriority: .fittingSizeLevel
//        )
//        
//        return size
        
        // Фиксированный размер вью
        CGSize(
            width: collectionView.bounds.width,
            height: params.headerHeight
        )
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview() {
    TabBarController()
}
#endif
