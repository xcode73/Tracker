//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 04.02.2025.
//

import AppMetricaCore

protocol AnalyticsServiceProtocol {
    func report(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem?)
}

enum AnalyticsEvent: String {
    case open
    case close
    case click
}

enum AnalyticsScreen: String {
    case main = "Main"
    case statistics = "Statistics"
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track
    case filter
    case edit
    case delete
}

final class AnalyticsService {
    private var serviceType = String()

    init() {
        let serviceType = ProcessInfo.processInfo.environment["analytics_service"]
        guard serviceType != "null" else { return }

        guard
            let configuration = AppMetricaConfiguration(apiKey: APIKeys.appMetricaKey)
        else {
            print("ERROR: AppMetrica configuration error")
            return
        }

        AppMetrica.activate(with: configuration)
    }

    private func toDictionary(screen: AnalyticsScreen, item: AnalyticsItem?) -> [AnyHashable: Any] {
        var dict: [AnyHashable: Any] = [:]
        dict["screen"] = screen.rawValue

        if let item {
            dict["item"] = item.rawValue
        }
        return dict
    }
}

extension AnalyticsService: AnalyticsServiceProtocol {
    func report(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem?) {
        guard serviceType != "null" else { return }
        AppMetrica.reportEvent(
            name: event.rawValue,
            parameters: toDictionary(
                screen: screen,
                item: item
            ), onFailure: { error in
                print("REPORT ERROR: %@", error.localizedDescription)
            })
    }
}

extension AnalyticsServiceProtocol {
    func report(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem? = nil) {
        report(event: event, screen: screen, item: item)
    }
}
