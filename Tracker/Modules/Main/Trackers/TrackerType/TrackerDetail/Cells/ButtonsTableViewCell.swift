//
//  ButtonsTableViewCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 27.09.2024.
//

import UIKit

final class ButtonsTableViewCell: UITableViewCell {
    // MARK: - UI Components
    private let containerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var cancelButton: UIButton = {
        let view = UIButton()
        view.titleLabel?.text = "Отменить"
        view.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        view.setTitleColor(.ypRed, for: .normal)
        view.layer.cornerRadius = 16
        view.backgroundColor = .ypWhite
        view.layer.borderColor = UIColor.ypRed.cgColor
        view.layer.borderWidth = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private var addButton: UIButton = {
        let view = UIButton()
        view.titleLabel?.text = "Создать"
        view.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        view.setTitleColor(.white, for: .normal)
        view.layer.cornerRadius = 16
        view.backgroundColor = .ypBlack
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
    
    private func setupViews() {
        selectionStyle = .none
        contentView.addSubview(containerStackView)
        containerStackView.addArrangedSubview(cancelButton)
        containerStackView.addArrangedSubview(addButton)
        
        NSLayoutConstraint.activate([
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}


// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("Regular") {
    let navigationController = UINavigationController(rootViewController: DetailTableViewController(tableType: .regular, categories: nil, currentDate: nil))
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}
#endif
