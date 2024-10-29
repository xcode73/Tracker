//
//  CategoryCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 17.10.2024.
//

import UIKit

final class CategoryCell: UITableViewCell {
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
        view.image = UIImage(systemName: "checkmark")
        view.tintColor = .ypBlue
        view.isHidden = true
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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        disclosureIndicatorImageView.isHidden = !selected
    }
    
    // MARK: - Configuration
    func configure(with category: TrackerCategory, cellPosition: CellPosition) {
        titleLabel.text = category.title
        
        switch cellPosition {
        case .first:
            containerView.layer.masksToBounds = true
            containerView.layer.cornerRadius = 16
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .single:
            containerView.layer.cornerRadius = 16
        case .last:
            containerView.layer.masksToBounds = true
            containerView.layer.cornerRadius = 16
            containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .regular:
            containerView.layer.cornerRadius = 0
        }
    }
    
    func configureSelectedView() -> UIView {
        return containerView
    }
    
    // MARK: - Constraints
    private func setupViews() {
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(verticalStackView)
        addImageViewDisclosureIndicator()
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
    
    private func addImageViewDisclosureIndicator() {
        horizontalStackView.addArrangedSubview(disclosureIndicatorImageView)
        
        NSLayoutConstraint.activate([
            disclosureIndicatorImageView.widthAnchor.constraint(equalToConstant: 24),
            disclosureIndicatorImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("Categories") {
    let selectedCategory = TrackerCategory(id: UUID(), title: "Quux", trackers: [])
    let categories: [TrackerCategory] = [
        selectedCategory,
        TrackerCategory(id: UUID(), title: "Foo", trackers: []),
        TrackerCategory(id: UUID(), title: "Baz", trackers: []),
        TrackerCategory(id: UUID(), title: "Bar", trackers: []),
        TrackerCategory(id: UUID(), title: "Foo", trackers: []),
        TrackerCategory(id: UUID(), title: "Baz", trackers: []),
        TrackerCategory(id: UUID(), title: "Bar", trackers: []),
        TrackerCategory(id: UUID(), title: "Foo", trackers: []),
        TrackerCategory(id: UUID(), title: "Baz", trackers: []),
        TrackerCategory(id: UUID(), title: "Bar", trackers: []),
    ]
    let navigationController = UINavigationController(
        rootViewController: CategoriesViewController(categories: categories, selectedCategory: selectedCategory)
    )
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}
#endif
