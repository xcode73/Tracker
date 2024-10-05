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
        view.distribution = .fillEqually

        view.translatesAutoresizingMaskIntoConstraints = false
        
        
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 17, weight: .regular)
        view.textColor = .ypBlack
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 17, weight: .regular)
        view.textColor = .ypGray
        view.text = "Важное"
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var disclosureIndicatorImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "chevron.right")
        view.tintColor = .ypGray
        
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
    
    func configure(with trackerSettings: String, isRegular: Bool) {
        titleLabel.text = trackerSettings
        switch trackerSettings {
        case "Категория":
            addDescriptionLabel()
            containerView.layer.masksToBounds = true
            containerView.layer.cornerRadius = 16
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            if isRegular {
                addSeparatorView()
            }
        case "Расписание":
            containerView.layer.masksToBounds = true
            containerView.layer.cornerRadius = 16
            containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            separatorView.isHidden = true
        default:
            break
        }
    }
    
    // MARK: - Constraints
    private func addDescriptionLabel() {
        verticalStackView.addArrangedSubview(descriptionLabel)
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
    
    private func setupViews() {
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(verticalStackView)
        horizontalStackView.addArrangedSubview(disclosureIndicatorImageView)
        verticalStackView.addArrangedSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 75),
            
            horizontalStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            horizontalStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            horizontalStackView.heightAnchor.constraint(equalToConstant: 46),
            horizontalStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            disclosureIndicatorImageView.widthAnchor.constraint(equalToConstant: 10),
            disclosureIndicatorImageView.heightAnchor.constraint(equalToConstant: 17),
        ])
    }
}

// MARK: - Preview
@available(iOS 17, *)
#Preview() {
    let navigationController = UINavigationController(rootViewController: TrackerDetailTableViewController(tracker: nil, isRegular: true))
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}
