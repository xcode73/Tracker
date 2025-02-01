//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 26.10.2024.
//

import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCollectionViewCell"
    private var selectedColor: UIColor?

    override var isSelected: Bool {
        didSet {
            contentView.layer.borderWidth = isSelected ? 3 : 0
            contentView.layer.borderColor = isSelected ? selectedColor?
                .withAlphaComponent(0.3).cgColor : UIColor.clear.cgColor
        }
    }

    private lazy var colorImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with color: String) {
        colorImageView.backgroundColor = UIColor(named: color)
        selectedColor = UIColor(named: color)
    }

    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubview(colorImageView)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            colorImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorImageView.heightAnchor.constraint(equalToConstant: 40),
            colorImageView.widthAnchor.constraint(equalToConstant: 40)
        ])
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
