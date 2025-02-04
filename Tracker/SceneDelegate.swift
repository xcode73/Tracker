//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 20.09.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        let analyticsService: AnalyticsServiceProtocol

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            analyticsService = appDelegate.analyticsService
        } else {
            analyticsService = AnalyticsService() // Фолбэк, если AppDelegate не найден
        }

        window = UIWindow(windowScene: scene)
        window?.rootViewController = SplashViewController(analyticsService: analyticsService)
        window?.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        try? Constants.appDelegate().trackerDataStore.saveContext()
    }
}
