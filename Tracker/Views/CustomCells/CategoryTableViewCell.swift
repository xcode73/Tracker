//
//  CategoryTableViewCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 17.10.2024.
//

import UIKit

final class CategoryTableViewCell: UITableViewCell {
    // MARK: - UI Components
    private lazy var horizontalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.alignment = .center
        view.spacing = 16
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

    private lazy var disclosureIndicatorImageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .ypGray
        view.contentMode = .center
        view.image = Icons.checkmark
        view.tintColor = .ypBlue
        view.isHidden = true
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        /// Configure the view for the selected state
        disclosureIndicatorImageView.isHidden = !selected
    }

    override static var layerClass: AnyClass {
        InsetsGroupedLayer.self
    }

    // MARK: - Config
    func configure(with categoryUI: CategoryUI ) {
        titleLabel.text = categoryUI.title
    }

    func configureSelectedView() -> UIView {
        return contentView
    }

    // MARK: - Constraints
    private func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = .ypBackground
        contentView.addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(titleLabel)
        addImageViewDisclosureIndicator()

        NSLayoutConstraint.activate([
            horizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            horizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            horizontalStackView.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
    }

    private func addImageViewDisclosureIndicator() {
        horizontalStackView.addArrangedSubview(disclosureIndicatorImageView)

        NSLayoutConstraint.activate([
            disclosureIndicatorImageView.widthAnchor.constraint(equalToConstant: 24),
            disclosureIndicatorImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}
