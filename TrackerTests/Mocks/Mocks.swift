//
//  Mocks.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 03.02.2025.
//

import Foundation

struct MockTracker {
    let name: String
    let color: String
    let emoji: String
    let categoryName: String
    let isPinned: Bool
    let hasSchedule: Bool
}

enum Mocks {
    static let trackers: [MockTracker] = [
        MockTracker(
            name: "Bar",
            color: Constants.selectionColors[0],
            emoji: Constants.emojis[0],
            categoryName: "Foo",
            isPinned: false,
            hasSchedule: false
        ),
        MockTracker(
            name: "Quux",
            color: Constants.selectionColors[1],
            emoji: Constants.emojis[1],
            categoryName: "Foo",
            isPinned: false,
            hasSchedule: true
        ),
        MockTracker(
            name: "Quuux",
            color: Constants.selectionColors[2],
            emoji: Constants.emojis[2],
            categoryName: "Baz",
            isPinned: false,
            hasSchedule: false
        ),
        MockTracker(
            name: "Quuuux",
            color: Constants.selectionColors[3],
            emoji: Constants.emojis[3],
            categoryName: "Baz",
            isPinned: true,
            hasSchedule: true
        ),
        MockTracker(
            name: "Quuuuux",
            color: Constants.selectionColors[4],
            emoji: Constants.emojis[4],
            categoryName: "Baz",
            isPinned: true,
            hasSchedule: false
        ),
        MockTracker(
            name: "Quuuuuux",
            color: Constants.selectionColors[5],
            emoji: Constants.emojis[5],
            categoryName: "Baz",
            isPinned: false,
            hasSchedule: false
        )
    ]
}
