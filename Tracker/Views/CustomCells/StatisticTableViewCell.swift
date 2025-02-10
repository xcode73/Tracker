//
//  StatisticTableViewCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 04.02.2025.
//

import UIKit

final class StatisticTableViewCell: UITableViewCell {
    // MARK: - UI Components
    private lazy var containerView: GradientBorderView = {
        let view = GradientBorderView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var statisticVStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.alignment = .leading
        view.spacing = 7
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var valueLabel: UILabel = {
        let view = UILabel()
        view.font = Fonts.ypBold34
        view.textColor = .ypBlack
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = Fonts.ypMedium12
        view.textColor = .ypBlack
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Config
    func configure(with statisticUI: StatisticUI) {
        titleLabel.text = statisticUI.title
        valueLabel.text = String(statisticUI.value)
    }

    // MARK: - UI Setup
    private func setupUI() {
        setupLayout()
        setupContainerViewConstraints()
        setupStatisticVStackView()
    }

    private func setupLayout() {
        contentView.addSubview(containerView)
        containerView.addSubview(statisticVStackView)
        statisticVStackView.addArrangedSubview(valueLabel)
        statisticVStackView.addArrangedSubview(titleLabel)
    }

    private func setupContainerViewConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    private func setupStatisticVStackView() {
        NSLayoutConstraint.activate([
            statisticVStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            statisticVStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            statisticVStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            statisticVStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
}
