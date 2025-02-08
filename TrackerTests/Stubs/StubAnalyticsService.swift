//
//  StubAnalyticsService.swift
//  TrackerTests
//
//  Created by Nikolai Eremenko on 06.02.2025.
//

import Foundation
@testable import Tracker

final class StubAnalyticsService: AnalyticsServiceProtocol {
    func track(event: AnalyticsEvent) {}
}
