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
        guard let scene = (scene as? UIWindowScene) else {
            print("Ошибка: UIWindowScene не найден")
            return
        }

        guard
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            fatalError("could not get app delegate ")
        }

        let analyticsService = appDelegate.analyticsService
        let dataStore = appDelegate.dataStore

        window = UIWindow(windowScene: scene)
        window?.rootViewController = SplashViewController(dataStore: dataStore,
                                                          analyticsService: analyticsService)
        window?.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        guard
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            fatalError("could not get app delegate ")
        }

        do {
            try appDelegate.dataStore.saveContext()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
