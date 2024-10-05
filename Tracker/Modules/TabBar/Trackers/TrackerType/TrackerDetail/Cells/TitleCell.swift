//
//  SearchTableViewCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 27.09.2024.
//

import UIKit

protocol TitleCellDelegate: AnyObject {
    func titleChanged(title: String?)
}

final class TitleCell: UITableViewCell {
    weak var delegate: TitleCellDelegate?
    
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
        view.font = .systemFont(ofSize: 17, weight: .regular)
        view.returnKeyType = .done
        view.clearButtonMode = .whileEditing
        view.delegate = self

        view.addTarget(self, action: #selector(TitleCell.textFieldDidChange(_:)), for: .editingChanged)
        view.placeholder = "Введите название трекера"
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
    
    func configure(with title: String) {
        titleTextField.text = title
    }
    
    // MARK: - Actions
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        print(textField.text ?? "")
        delegate?.titleChanged(title: textField.text)
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
extension TitleCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= 38
    }
}

// MARK: - Preview
@available(iOS 17, *)
#Preview() {
    let navigationController = UINavigationController(rootViewController: TrackerDetailTableViewController(tracker: nil, isRegular: true))
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}
