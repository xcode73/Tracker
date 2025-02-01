//
//  ColorsTableViewCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 27.09.2024.
//

import UIKit

protocol ColorsCellDelegate: AnyObject {
    func didSelectColor(color: String)
}

final class ColorsTableViewCell: UITableViewCell {
    weak var delegate: ColorsCellDelegate?
    private var colors = [String]()
    private var selectedColor: String?

    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(ColorCollectionViewCell.self,
                      forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
        view.allowsMultipleSelection = false
        view.dataSource = self
        view.delegate = self
        return view
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    func configure(with colors: [String], selectedColor: String?) {
        self.colors = colors
        self.selectedColor = selectedColor
    }

    private func setupViews() {
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
}

// MARK: - UICollectionViewDataSource
extension ColorsTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colors.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? ColorCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: colors[indexPath.row])
        cell.isSelected = false

        if colors[indexPath.row] == selectedColor {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
            cell.isSelected = true
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ColorsTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 52, height: 52)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedColor = colors[indexPath.row]
        delegate?.didSelectColor(color: colors[indexPath.row])
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("Special") {
    let dataStore = Constants.appDelegate().trackerDataStore
    let viewController = TrackerTableViewController(
        tableType: .special(Date()),
        dataStore: dataStore
    )
    let navigationController = UINavigationController(rootViewController: viewController)
    navigationController.modalPresentationStyle = .pageSheet

    return navigationController
}

@available(iOS 17, *)
#Preview("Regular") {
    let dataStore = Constants.appDelegate().trackerDataStore
    let viewController = TrackerTableViewController(
        tableType: .regular,
        dataStore: dataStore
    )
    let navigationController = UINavigationController(rootViewController: viewController)
    navigationController.modalPresentationStyle = .pageSheet

    return navigationController
}
#endif
