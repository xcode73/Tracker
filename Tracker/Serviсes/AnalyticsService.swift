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

final class AnalyticsService: AnalyticsServiceProtocol {
    func report(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem?) {
        AppMetrica.reportEvent(
            name: event.rawValue,
            parameters: toDictionary(
                screen: screen,
                item: item
            ), onFailure: { error in
                print("REPORT ERROR: %@", error.localizedDescription)
            })
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

extension AnalyticsServiceProtocol {
    func report(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem? = nil) {
        report(event: event, screen: screen, item: item)
    }
}
