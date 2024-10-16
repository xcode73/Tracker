//
//  SettingsTableViewCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 27.09.2024.
//

import UIKit

protocol SettingsCellDelegate: AnyObject {
    func trackerTypeCellDidTapped(_ cell: SettingsCell)
}

final class SettingsCell: UITableViewCell {
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
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var disclosureIndicatorSwitch: UISwitch = {
        let view = UISwitch()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    //MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
//    func configureForCategory(category: String, selected: Bool?) {
//        titleLabel.text = category
//        disclosureIndicatorImageView.image = UIImage(systemName: "checkmark")
//        
//        if let selected = selected {
//            if selected {
//                disclosureIndicatorImageView.tintColor = .ypBlue
//            }
//        }
//    }
    
    func configure(
        itemTitle: String,
        cellPosition: CellPosition,
        category: TrackerCategory?,
        tracker: Tracker?,
        indexPath: IndexPath,
        cellType: TableCellType,
        selected: Bool?
    ) {
        titleLabel.text = itemTitle
        
        switch cellPosition {
        case .first:
            containerView.layer.cornerRadius = 16
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            separatorView.isHidden = false
        case .single:
            containerView.layer.cornerRadius = 16
            separatorView.isHidden = true
        case .last:
            containerView.layer.cornerRadius = 16
            containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            separatorView.isHidden = true
        case .regular:
            separatorView.isHidden = false
        }
        
        switch cellType {
        case .chevron:
            addImageViewDisclosureIndicator()
            disclosureIndicatorImageView.image = UIImage(systemName: "chevron.right")
            
            if indexPath.row == 0 {
                if let category = category {
                    descriptionLabel.text = category.title
                }
            }
            
            if indexPath.row == 1 {
                if let tracker = tracker {
                    var schedule = ""
                    for day in tracker.schedule {
                        schedule += day.localizedShortName
                        if day != tracker.schedule.last {
                            schedule += ", "
                        }
                    }
                    descriptionLabel.text = schedule
                }
            }
        case .checkmark:
            if let selected = selected {
                if selected {
                    disclosureIndicatorImageView.image = UIImage(systemName: "checkmark")
                    disclosureIndicatorImageView.tintColor = .ypBlue
                    addImageViewDisclosureIndicator()
                }
            }
        case .`switch`:
            addSwitchDisclosureIndicator()
            disclosureIndicatorImageView.isHidden = true
            disclosureIndicatorSwitch.isHidden = false
        }
    }
    
    // MARK: - Constraints
    private func setupViews() {
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.addSubview(horizontalStackView)
        addSeparatorView()
        horizontalStackView.addArrangedSubview(verticalStackView)
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
    
    private func addSeparatorView() {
        containerView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: horizontalStackView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: horizontalStackView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func addSwitchDisclosureIndicator() {
        horizontalStackView.addArrangedSubview(disclosureIndicatorSwitch)
    }
    
    private func addImageViewDisclosureIndicator() {
        horizontalStackView.addArrangedSubview(disclosureIndicatorImageView)
        
        NSLayoutConstraint.activate([
            disclosureIndicatorImageView.widthAnchor.constraint(equalToConstant: 24),
            disclosureIndicatorImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
}

// MARK: - Preview
//#if DEBUG
//@available(iOS 17, *)
//#Preview("Special") {
//    let navigationController = UINavigationController(rootViewController: DetailTableViewController(tableType: .special, currentDate: nil))
//    navigationController.modalPresentationStyle = .pageSheet
//    
//    return navigationController
//}
//
//@available(iOS 17, *)
//#Preview("Regular") {
//    let navigationController = UINavigationController(rootViewController: DetailTableViewController(tableType: .regular, currentDate: nil))
//    navigationController.modalPresentationStyle = .pageSheet
//    
//    return navigationController
//}

//@available(iOS 17, *)
//#Preview("Edit") {
//    let category = TrackerCategory(id: UUID(), title: "Foo", trackers: [
//        Tracker(
//            id: UUID(),
//            title: "Lorem ipsum dolor sit amet, consetetur",
//            color: Constants.selectionColors[4],
//            emoji: Constants.emojis[0],
//            schedule: [WeekDay.tuesday, WeekDay.friday],
//            daysCompleted: 1,
//            isRegular: true
//        )
//    ])
//    let tracker = category.trackers![0]
//    let navigationController = UINavigationController(rootViewController: DetailTableViewController(tableType: .edit(tracker, category), currentDate: nil))
//    navigationController.modalPresentationStyle = .pageSheet
//    
//    return navigationController
//}
//
//@available(iOS 17, *)
//#Preview("Categories") {
//    let category = TrackerCategory(id: UUID(), title: "Foo", trackers: [])
//    let navigationController = UINavigationController(rootViewController: DetailTableViewController(tableType: .categories(category), currentDate: nil))
//    navigationController.modalPresentationStyle = .pageSheet
//    
//    return navigationController
//}
//#endif
