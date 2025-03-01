//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 30.09.2024.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func changeTrackerState(tracker: TrackerUI?, record: RecordUI?)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    weak var delegate: TrackerCellDelegate?
    static let reuseIdentifier = "TrackerCollectionViewCell"
    private var tracker: TrackerUI?
    private var record: RecordUI?

    // MARK: - UI Components
    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 8
        view.distribution = .equalSpacing
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var horizontalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .equalCentering
        view.spacing = 8
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.ypTrackerBorder.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var emojiLabel: UILabel = {
        let view = UILabel()
        view.font = Fonts.ypRegular12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var pinImageView: UIImageView = {
        let view = UIImageView()
        view.image = Icons.pin
        view.tintColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var emojiBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.backgroundColor = .ypEmojiBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = Fonts.ypMedium12
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.textColor = .white
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var daysCompletedLabel: UILabel = {
        let view = UILabel()
        view.font = Fonts.ypMedium12
        view.textColor = .ypBlack
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var checkButton: UIButton = {
        let view = UIButton(type: .custom)
        view.layer.cornerRadius = 17
        view.tintColor = .white
        view.backgroundColor = .clear
        view.addTarget(self, action: #selector(didTapCheckButton), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
//            tabBar.addTopBorder(color: .ypTabBarBorder, height: 1)
//        }
//    }

    // MARK: - Configuration
    func configure(
        tracker: TrackerUI,
        record: RecordUI?,
        completedTitle: String
    ) {
        self.tracker = tracker
        self.record = record

        colorView.backgroundColor = UIColor(named: tracker.color)
        checkButton.backgroundColor = UIColor(named: tracker.color)
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        pinImageView.isHidden = !tracker.isPinned
        daysCompletedLabel.text = completedTitle

        if record == nil {
            checkButton.layer.opacity = 1
            checkButton.setImage(Icons.plus, for: .normal)
        } else {
            checkButton.layer.opacity = 0.3
            checkButton.setImage(Icons.checkmark, for: .normal)
        }
    }

    func configureSelectedView() -> UIView {
        return colorView
    }

    // MARK: - Actions
    @objc
    private func didTapCheckButton() {
        delegate?.changeTrackerState(
            tracker: tracker,
            record: record
        )
    }

    // MARK: - Constraints
    private func setupUI() {
        contentView.backgroundColor = .clear
        contentView.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(colorView)
        colorView.addSubview(emojiBackgroundView)
        colorView.addSubview(titleLabel)
        colorView.addSubview(pinImageView)
        emojiBackgroundView.addSubview(emojiLabel)
        verticalStackView.addArrangedSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(daysCompletedLabel)
        horizontalStackView.addArrangedSubview(checkButton)

        NSLayoutConstraint.activate([
            verticalStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            verticalStackView.heightAnchor.constraint(equalTo: contentView.heightAnchor),

            colorView.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 90),

            emojiBackgroundView.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            emojiBackgroundView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),

            pinImageView.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            pinImageView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 19),
            pinImageView.widthAnchor.constraint(equalToConstant: 13),
            pinImageView.heightAnchor.constraint(equalToConstant: 13),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),

            daysCompletedLabel.widthAnchor.constraint(equalToConstant: 101),

            checkButton.widthAnchor.constraint(equalToConstant: 34),
            checkButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
}
