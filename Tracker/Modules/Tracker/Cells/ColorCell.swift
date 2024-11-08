//
//  ColorCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 26.10.2024.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCell"
    private var selectedColor: UIColor?
    
    override var isSelected: Bool {
        didSet {
            contentView.layer.borderWidth = isSelected ? 3 : 0
            contentView.layer.borderColor = isSelected ? selectedColor?.withAlphaComponent(0.3).cgColor : UIColor.clear.cgColor
        }
    }
    
    private lazy var colorImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 8
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with color: String) {
        colorImageView.backgroundColor = UIColor(named: color)
        selectedColor = UIColor(named: color)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubview(colorImageView)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            colorImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorImageView.heightAnchor.constraint(equalToConstant: 40),
            colorImageView.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("Regular") {
    let navigationController = UINavigationController(rootViewController: TrackerTableViewController(tableType: .regular, categories: []))
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}

@available(iOS 17, *)
#Preview("Edit Regular") {
    let selectedCategory = TrackerCategory(title: "Foo", trackers: [
        Tracker(
            id: UUID(),
            title: "Lorem ipsum dolor sit amet, consetetur",
            color: Constants.selectionColors[4],
            emoji: Constants.emojis[0],
            schedule: Schedule(type: .regular([WeekDay.tuesday, WeekDay.friday]))
        )
    ])
    let categories: [TrackerCategory] = [
        selectedCategory,
        TrackerCategory(title: "Baz", trackers: []),
        TrackerCategory(title: "Bar", trackers: []),
    ]
    
    let tracker = categories[0].trackers[0]
    let counterTitle = "5 дней"
    let vc = TrackerTableViewController(tableType: .edit(tracker, selectedCategory, counterTitle), categories: categories)
    let navigationController = UINavigationController(rootViewController: vc)
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}
#endif
