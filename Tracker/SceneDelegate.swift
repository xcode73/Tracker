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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    print("AppDelegate найден после задержки")
                } else {
                    print("Ошибка: AppDelegate не найден")
                }
            }
            return
        }

        let analyticsService = appDelegate.analyticsService
        let dataStore = appDelegate.dataStore

        window = UIWindow(windowScene: scene)
        window?.rootViewController = SplashViewController(dataStore: dataStore,
                                                          analyticsService: analyticsService)
        window?.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        try? Constants.appDelegate().dataStore.saveContext()
    }
}
