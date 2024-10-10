//
//  OnboardingCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 30.09.2024.
//

import UIKit

final class OnboardingCell: UICollectionViewCell {
    static let reuseIdentifier = "OnboardingCell"
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
            
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview() {
    OnboardingViewController()
}
#endif
