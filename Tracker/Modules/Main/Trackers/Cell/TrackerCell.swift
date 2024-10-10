//
//  TrackerCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 30.09.2024.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func changeTrackerState(for tracker: Tracker, at indexPath: IndexPath)
}

final class TrackerCell: UICollectionViewCell {
    weak var delegate: TrackerCellDelegate?
    static let reuseIdentifier = "TrackerCell"
    private var tracker: Tracker?
    private var indexPath: IndexPath?
    
    // MARK: - UI Components
    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 8
        view.distribution = .equalSpacing
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .equalCentering
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.ypBackground.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 12, weight: .regular)
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
        view.font = .systemFont(ofSize: 12, weight: .medium)
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.textColor = .ypWhite
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dayLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 12, weight: .medium)
        view.textColor = .ypBlack
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var checkButton: UIButton = {
        let view = UIButton(type: .custom)
        view.layer.cornerRadius = 17
        view.tintColor = .ypWhite
        view.addTarget(self, action: #selector(didTapCheckButton), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configuration
    func configure(
        with trackerModel: Tracker,
        recordModel: TrackerRecord?,
        indexPath: IndexPath
    ) {
        guard let schedule = trackerModel.schedule else { return }
        
        self.tracker = trackerModel
        self.indexPath = indexPath
        
        colorView.backgroundColor = UIColor(named: trackerModel.color)
        checkButton.backgroundColor = UIColor(named: trackerModel.color)
        emojiLabel.text = trackerModel.emoji
        titleLabel.text = trackerModel.name
        
        let dayCount = schedule.count
        switch dayCount {
        case 1:
            dayLabel.text = "\(dayCount) день"
        case 2...4:
            dayLabel.text = "\(dayCount) дня"
        case 7:
            dayLabel.text = "Каждый день"
        default:
            dayLabel.text = "\(dayCount) дней"
        }
        
        if recordModel == nil {
            checkButton.layer.opacity = 1
            checkButton.setImage(UIImage(systemName: "plus"), for: .normal)
        } else {
            checkButton.layer.opacity = 0.3
            checkButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        }
    }
    
    func configureSelectedView() -> UIView {
        return colorView
    }
    
    //MARK: - Constraints
    private func setupUI() {
        contentView.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(colorView)
        colorView.addSubview(emojiBackgroundView)
        colorView.addSubview(titleLabel)
        emojiBackgroundView.addSubview(emojiLabel)
        verticalStackView.addArrangedSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(dayLabel)
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
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),

            dayLabel.widthAnchor.constraint(equalToConstant: 101),
            
            checkButton.widthAnchor.constraint(equalToConstant: 34),
            checkButton.heightAnchor.constraint(equalToConstant: 34),
        ])
    }
    
    // MARK: - Actions
    @objc
    private func didTapCheckButton() {
        guard let tracker = tracker,
              let indexPath = indexPath
        else {
            return
        }
        
        delegate?.changeTrackerState(for: tracker, at: indexPath)
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview() {
    TabBarController()
}
#endif
