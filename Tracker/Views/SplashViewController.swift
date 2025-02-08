//
//  SplashViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 22.09.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    private let dataStore: DataStoreProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private var trackerStore: TrackerStoreProtocol?
    private var categoryStore: CategoryStoreProtocol?
    private var scheduleStore: ScheduleStoreProtocol?
    private var recordStore: RecordStoreProtocol?
    private var statisticStore: StatisticStoreProtocol?

    private var isOnboardingCompleted = false

    private lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        view.image = .icLogo
        view.tintColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init
    init(
        dataStore: DataStoreProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.dataStore = dataStore
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
        setupTrackerStore()
        setupScheduleStore()
        setupRecordStore()
        setupCategoryStore()
        setupStatisticStore()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        isOnboardingCompleted = UserDefaults.standard.isOnboardingCompleted

        if dataStore is NullStore {
            showStoreErrorAlert("Invalid store configuration")
        } else {
            showOnboarding()
            showMainScreen()
        }

    }

    private func showOnboarding() {
        if !isOnboardingCompleted {
            switchToOnboardingViewController()
        }
    }

    private func showMainScreen() {
        if isOnboardingCompleted {
            switchToTabBarController()
        }
    }

    // MARK: - Setup Stors
    private func setupTrackerStore() {
        do {
            trackerStore = try TrackerStore(dataStore: dataStore)
        } catch {
            showStoreErrorAlert(
                (error as? TrackerStoreError)?.userFriendlyMessage ?? error.localizedDescription
            )
        }
    }

    private func setupScheduleStore() {
        do {
            scheduleStore = try ScheduleStore(dataStore: dataStore)
        } catch {
            showStoreErrorAlert(
                (error as? ScheduleStoreError)?.userFriendlyMessage ?? error.localizedDescription
            )
        }
    }

    private func setupRecordStore() {
        do {
            recordStore = try RecordStore(dataStore: dataStore)
        } catch {
            showStoreErrorAlert(
                (error as? RecordStoreError)?.userFriendlyMessage ?? error.localizedDescription
            )
        }
    }

    private func setupCategoryStore() {
        do {
            categoryStore = try CategoryStore(dataStore)
        } catch {
            showStoreErrorAlert(
                (error as? CategoryStoreError)?.userFriendlyMessage ?? error.localizedDescription
            )
        }
    }

    private func setupStatisticStore() {
        do {
            statisticStore = try StatisticStore(dataStore: dataStore)
        } catch {
            showStoreErrorAlert(
                (error as? StatisticStoreError)?.userFriendlyMessage ?? error.localizedDescription
            )
        }
    }

    // MARK: - Navigation
    private func switchToOnboardingViewController() {
        guard let statisticStore else { return }

        let viewController = OnboardingViewController(statisticStore: statisticStore)
        viewController.onboardingDelegate = self
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: false)
    }

    private func switchToTabBarController() {
        guard let trackerStore = trackerStore,
              let scheduleStore = scheduleStore,
              let recordStore = recordStore,
              let categoryStore = categoryStore,
              let statisticStore = statisticStore else {
            showStoreErrorAlert("Invalid store configuration")
            return
        }

        let tabBarController = TabBarController(
            trackerStore: trackerStore,
            scheduleStore: scheduleStore,
            recordStore: recordStore,
            categoryStore: categoryStore,
            statisticStore: statisticStore,
            analyticsService: analyticsService
        )

        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }

        window.rootViewController = tabBarController
    }

    // MARK: - Alerts
    func showStoreErrorAlert(_ message: String) {
        let model = AlertModel(
            title: NSLocalizedString("alertTitleStoreError", comment: ""),
            message: message,
            buttons: [.cancelButton],
            identifier: "Store Error Alert",
            completion: nil
        )

        AlertPresenter.showAlert(on: self, model: model)
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
