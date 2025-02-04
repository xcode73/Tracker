//
//  SplashViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.09.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    private let analyticsService: AnalyticsServiceProtocol
    // MARK: - UI Components
    private lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        view.image = .icLogo
        view.tintColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(analyticsService: AnalyticsServiceProtocol) {
        self.analyticsService = analyticsService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if UserDefaults.standard.isOnboardingCompleted {
            switchToTabBarController()
        } else {
            switchToOnboardingViewController()
        }
    }

    // MARK: - Navigation
    private func switchToOnboardingViewController() {
        let viewController = OnboardingViewController()
        viewController.onboardingDelegate = self
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: false)
    }

    private func switchToTabBarController() {
        let tabBarController = TabBarController(analyticsService: analyticsService)

        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }

        window.rootViewController = tabBarController
    }

    // MARK: - Constraints
    private func setupViews() {
        view.backgroundColor = .ypBlue
        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - OnboardingViewControllerDelegate
extension SplashViewController: OnboardingViewControllerDelegate {
    func onboardingCompleted() {
        dismiss(animated: true)
    }
}

// MARK: - Preview
@available(iOS 17, *)
#Preview() {
    let analyticsService = AnalyticsService()
    SplashViewController(analyticsService: analyticsService)
}
