//
//  SettingsTableViewCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 27.09.2024.
//

import UIKit

protocol SettingsCellDelegate: AnyObject {
    func trackerTypeCellDidTapped(_ cell: SettingsTableViewCell)
}

final class SettingsTableViewCell: UITableViewCell {
    weak var delegate: SettingsCellDelegate?

    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackground
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var horizontalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.alignment = .center
        view.spacing = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .leading
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Fonts.ypRegular17
        view.textColor = .ypBlack
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Fonts.ypRegular17
        view.textColor = .ypGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var disclosureIndicatorImageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .ypGray
        view.contentMode = .center
        view.image = Constants.Icons.chevronRight
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    func configureSelectedView() -> UIView {
        return containerView
    }

    func configure(
        itemTitle: String,
        cellPosition: CellPosition,
        categoryTitle: String?,
        selectedWeekDays: [WeekDay]?,
        indexPath: IndexPath
    ) {
        titleLabel.text = itemTitle

        if indexPath.row == 0 {
            if let categoryTitle {
                descriptionLabel.text = categoryTitle
            }
        }

        if indexPath.row == 1 {
            if let selectedWeekDays {
                var orderedWeekDays = WeekDay.ordered()
                orderedWeekDays = orderedWeekDays.filter { selectedWeekDays.contains($0) }
                let schedule = orderedWeekDays.map { $0.localizedShortName }
                    .joined(separator: ", ")
                descriptionLabel.text = schedule
            }
            addSeparatorView()
        }
        cellStyle(cellPosition: cellPosition)
    }

    private func cellStyle(cellPosition: CellPosition) {
        switch cellPosition {
        case .first:
            containerView.layer.cornerRadius = 16
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .single:
            containerView.layer.cornerRadius = 16
        case .last:
            containerView.layer.cornerRadius = 16
            containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .regular:
            containerView.layer.cornerRadius = 0
        }
    }

    // MARK: - Constraints
    private func setupViews() {
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(verticalStackView)
        addImageViewDisclosureIndicator()
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 75),

            horizontalStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            horizontalStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            horizontalStackView.heightAnchor.constraint(equalToConstant: 46),
            horizontalStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    private func addImageViewDisclosureIndicator() {
        horizontalStackView.addArrangedSubview(disclosureIndicatorImageView)

        NSLayoutConstraint.activate([
            disclosureIndicatorImageView.widthAnchor.constraint(equalToConstant: 24),
            disclosureIndicatorImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    private func addSeparatorView() {
        containerView.addSubview(separatorView)

        NSLayoutConstraint.activate([
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            separatorView.topAnchor.constraint(equalTo: containerView.topAnchor)
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
