//
//  SplashViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.09.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "ic.logo")
        view.tintColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
}

private extension SplashViewController {
    // MARK: - Navigation
    func switchToOnboardingViewController() {
        let viewController = OnboardingViewController()
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: false)
    }
    
    func switchToTabBarController() {
        let tabBarController = TabBarController()
        
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        window.rootViewController = tabBarController
    }
    
    // MARK: - Constraints
    func setupViews() {
        view.backgroundColor = .ypBlue
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - Preview
@available(iOS 17, *)
#Preview() {
    SplashViewController()
}

