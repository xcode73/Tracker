//
//  AppDelegate.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 20.09.2024.
//

import UIKit
import CoreData
import AppMetricaCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var dataStore: DataStoreProtocol = {
        do {
            return try DataStore()
        } catch {
            return NullStore()
        }
    }()

    var analyticsService = AnalyticsService()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard
            let configuration = AppMetricaConfiguration(apiKey: APIKeys.appMetricaKey)
        else {
            print("Failed to initialize AppMetricaConfiguration")
            return true
        }

        AppMetrica.activate(with: configuration)

        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
