//
//  OnboardingContentViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 20.01.2025.
//

import UIKit

protocol OnboardingContentViewControllerDelegate: AnyObject {
    func didTapConfirmButton()
}

class OnboardingContentViewController: UIViewController {
    weak var delegate: OnboardingContentViewControllerDelegate?
    var onboardingItem: OnboardingItem

    // MARK: - UI Components
    private lazy var featureLabel: UILabel = {
        let view = UILabel()
        view.font = Fonts.ypBold32
        view.textAlignment = .center
        view.numberOfLines = 3
        view.textColor = .black
        view.text = onboardingItem.description
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.image = onboardingItem.image
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var confirmButton: UIButton = {
        let view = UIButton()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = .black
        view.titleLabel?.font = Fonts.ypMedium16
        view.setTitleColor(.white, for: .normal)
        view.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        view.setTitle(onboardingItem.buttonTitle, for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init
    init(onboardingItem: OnboardingItem) {
        self.onboardingItem = onboardingItem
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
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

    // MARK: - Constraints
    private func addBackgroundImageView() {
        view.addSubview(backgroundImageView)

        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func addFeatureLabel() {
        view.addSubview(featureLabel)

        NSLayoutConstraint.activate([
            featureLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            featureLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            featureLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 478)
        ])
    }

    private func addConfirmButton() {
        view.addSubview(confirmButton)

        NSLayoutConstraint.activate([
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 60),
            confirmButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -93)
        ])
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("Onboarding") {
    OnboardingViewController()
}
#endif
