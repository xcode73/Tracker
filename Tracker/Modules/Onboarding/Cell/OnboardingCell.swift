//
//  OnboardingCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 30.09.2024.
//

import UIKit

protocol OnboardingCellDelegate: AnyObject {
    func didTapConfirmButton()
}

final class OnboardingCell: UICollectionViewCell {
    static let reuseIdentifier = "OnboardingCell"
    
    weak var delegate: OnboardingCellDelegate?
    
    // MARK: - UI Components
    private lazy var featureLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 31, weight: .bold)
        view.textAlignment = .center
        view.numberOfLines = 3
        view.textColor = .black
        
        return view
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        
        return view
    }()
    
    private lazy var confirmButton: UIButton = {
        let view = UIButton()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = .black
        view.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        view.setTitleColor(.white, for: .normal)
        view.setTitle("Вот это технологии!", for: .normal)
        view.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        view.accessibilityIdentifier = "Switch To TabBar Button"
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
    func configure(with model: OnboardingPage) {
        backgroundImageView.image = model.image
        featureLabel.text = model.title
    }
    
    private func setupUI() {
        addBackgroundImageView()
        addFeatureLabel()
        addConfirmButton()
    }
    
    // MARK: - Action
    @objc
    private func didTapConfirmButton() {
        delegate?.didTapConfirmButton()
    }
    
    //MARK: - Constraints
    private func addBackgroundImageView() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func addFeatureLabel() {
        featureLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.addSubview(featureLabel)
        
        NSLayoutConstraint.activate([
            featureLabel.leadingAnchor.constraint(equalTo: backgroundImageView.leadingAnchor, constant: 16),
            featureLabel.trailingAnchor.constraint(equalTo: backgroundImageView.trailingAnchor, constant: -16),
            featureLabel.centerYAnchor.constraint(equalTo: backgroundImageView.centerYAnchor)
        ])
    }
    
    private func addConfirmButton() {
        contentView.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            confirmButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 60),
            confirmButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50)
        ])
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview() {
    OnboardingViewController()
}
#endif
