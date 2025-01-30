//
//  TitleTableViewCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 27.09.2024.
//

import UIKit

protocol TitleCellDelegate: AnyObject {
    func titleChanged(title: String)
    func didTapDoneButton(title: String)
}

final class TitleTableViewCell: UITableViewCell {
    weak var delegate: TitleCellDelegate?

    private let maxTitleLength = 38

    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackground
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleTextField: UITextField = {
        let view = UITextField()
        view.font = Constants.Fonts.ypRegular17
        view.returnKeyType = .done
        view.clearButtonMode = .whileEditing
        view.delegate = self
        view.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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

    // MARK: - Configuration
    func configure(with title: String?, placeholder: String) {
        titleTextField.placeholder = placeholder

        guard let title else { return }

        titleTextField.text = title
    }

    // MARK: - Actions
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        delegate?.titleChanged(title: text)
    }

    // MARK: - Setup
    func setupViews() {
        selectionStyle = .none
        contentView.addSubview(titleView)
        titleView.addSubview(titleTextField)

        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleTextField.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -16),
            titleTextField.topAnchor.constraint(equalTo: titleView.topAnchor),
            titleTextField.bottomAnchor.constraint(equalTo: titleView.bottomAnchor)
        ])
    }
}

// MARK: - UITextFieldDelegate
extension TitleTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.didTapDoneButton(title: textField.text ?? "")
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        return updatedText.count <= maxTitleLength
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {

        delegate?.didTapDoneButton(title: textField.text ?? "")
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
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
