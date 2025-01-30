//
//  ScheduleTableViewCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 29.09.2024.
//

import UIKit

protocol ScheduleCellDelegate: AnyObject {
    func scheduleCellSwitchDidTapped(_ cell: ScheduleTableViewCell)
}

class ScheduleTableViewCell: UITableViewCell {
    weak var delegate: ScheduleCellDelegate?

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
        view.distribution = .equalSpacing
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
        view.font = Fonts.ypRegular17
        view.textColor = .ypBlack
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var disclosureIndicatorSwitch: UISwitch = {
        let view = UISwitch()
        view.isOn = false
        view.onTintColor = .ypBlue
        view.addTarget(self, action: #selector(didTapSwitch), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
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

    // MARK: - Cell Config
    func configure(with weekDay: WeekDay, selected: Bool, cellPosition: CellPosition) {
        titleLabel.text = weekDay.localizedName

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

        if selected {
            disclosureIndicatorSwitch.isOn = true
        }
    }

    // MARK: - Actions
    @objc private func didTapSwitch(_ sender: UISwitch) {
        delegate?.scheduleCellSwitchDidTapped(self)
    }

    // MARK: - Constraints
    private func setupViews() {
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(verticalStackView)
        addSwitchDisclosureIndicator()
        verticalStackView.addArrangedSubview(titleLabel)

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

    private func addSwitchDisclosureIndicator() {
        horizontalStackView.addArrangedSubview(disclosureIndicatorSwitch)
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("Empty") {
    let navigationController = UINavigationController(rootViewController: ScheduleViewController(schedule: nil))
    navigationController.modalPresentationStyle = .pageSheet

    return navigationController
}

@available(iOS 17, *)
#Preview("Schedule") {
    let schedule: [WeekDay] = [.monday, .tuesday, .wednesday]
    let navigationController = UINavigationController(rootViewController: ScheduleViewController(schedule: schedule))
    navigationController.modalPresentationStyle = .pageSheet

    return navigationController
}
#endif
