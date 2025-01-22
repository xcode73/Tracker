//
//  EmojiCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 24.10.2024.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiCell"

    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? .ypLightGray : .clear
        }
    }

    private lazy var emojiLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Fonts.ypBold32
        view.textAlignment = .center
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

    func configure(with emoji: String) {
        emojiLabel.text = emoji
    }

    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubview(emojiLabel)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("Special") {
    let trackerDataStore = Constants.appDelegate().trackerDataStore
    let viewController = TrackerTableViewController(
        tableType: .special(Date()),
        trackerDataStore: trackerDataStore,
        indexPath: nil
    )
    let navigationController = UINavigationController(rootViewController: viewController)
    navigationController.modalPresentationStyle = .pageSheet

    return navigationController
}

@available(iOS 17, *)
#Preview("Regular") {
    let trackerDataStore = Constants.appDelegate().trackerDataStore
    let viewController = TrackerTableViewController(
        tableType: .regular,
        trackerDataStore: trackerDataStore,
        indexPath: nil
    )
    let navigationController = UINavigationController(rootViewController: viewController)
    navigationController.modalPresentationStyle = .pageSheet

    return navigationController
}
#endif
