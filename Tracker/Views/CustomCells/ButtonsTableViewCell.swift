//
//  ButtonsTableViewCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 27.09.2024.
//

import UIKit

protocol ButtonsCellDelegate: AnyObject {
    func didTapCancelButton()
    func didTapDoneButton()
}

final class ButtonsTableViewCell: UITableViewCell {
    weak var delegate: ButtonsCellDelegate?

    // MARK: - UI Components
    private lazy var containerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var cancelButton: UIButton = {
        let view = UIButton()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.setTitleColor(.ypRed, for: .normal)
        view.backgroundColor = .ypWhite
        view.layer.borderColor = UIColor.ypRed.cgColor
        view.layer.borderWidth = 1
        view.titleLabel?.font = Constants.Fonts.ypMedium16
        view.setTitleColor(.ypRed, for: .normal)
        view.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var doneButton: UIButton = {
        let view = UIButton()
        view.isEnabled = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.titleLabel?.font = Constants.Fonts.ypMedium16
        view.setTitleColor(.ypWhite, for: .normal)
        view.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
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

    func configure(with doneButtonTitle: String, cancelButtonTitle: String, isDoneButtonEnabled: Bool) {
        doneButton.setTitle(doneButtonTitle, for: .normal)
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        doneButton.isEnabled = isDoneButtonEnabled
        doneButton.backgroundColor = isDoneButtonEnabled ? .ypBlack : .ypGray
    }

    // MARK: - Actions
    @objc
    private func didTapDoneButton() {
        delegate?.didTapDoneButton()
    }

    @objc
    private func didTapCancelButton() {
        delegate?.didTapCancelButton()
    }

    // MARK: - Constraints
    private func setupViews() {
        selectionStyle = .none
        contentView.addSubview(containerStackView)
        containerStackView.addArrangedSubview(cancelButton)
        containerStackView.addArrangedSubview(doneButton)

        NSLayoutConstraint.activate([
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
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
