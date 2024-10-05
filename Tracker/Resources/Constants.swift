//
//  Constants.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 29.09.2024.
//

import UIKit

enum Constants {
    static let emojis: [String] = [
        "🙂", "😻", "🌺", "🐶","❤️", "😱", "😇", "😡","🥶",
        "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    
    static let selectionColors: [UIColor] = [
        .ypSelection1, .ypSelection2, .ypSelection3,
        .ypSelection4, .ypSelection5, .ypSelection6,
        .ypSelection7, .ypSelection8, .ypSelection9,
        .ypSelection10, .ypSelection11, .ypSelection12,
        .ypSelection13, .ypSelection14, .ypSelection15,
        .ypSelection16, .ypSelection17, .ypSelection18
    ]
    
    static let mockCategories: [TrackerCategory] = [
        TrackerCategory(
            title: "Foo Foo  Foo  Foo  Foo  Foo Foo Foo Foo Foo Foo Foo",
            trackers: [
                Tracker(
                    id: UUID(),
                    name: "Baz Bar Foo Quux Quuux Quuuux Quuuuuux",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[0],
                    schedule: [WeekDay.monday],
                    date: nil
                ),
                Tracker(
                    id: UUID(),
                    name: "Bar",
                    color: Constants.selectionColors[5],
                    emoji: Constants.emojis[9],
                    schedule: [WeekDay.friday, WeekDay.saturday],
                    date: nil
                )
            ]
        ),
        TrackerCategory(
            title: "Bar",
            trackers: [
                Tracker(
                    id: UUID(),
                    name: "Quux",
                    color: Constants.selectionColors[2],
                    emoji: Constants.emojis[1],
                    schedule: [WeekDay.monday, WeekDay.tuesday, WeekDay.friday, WeekDay.saturday, WeekDay.sunday],
                    date: nil
                ),
                Tracker(
                    id: UUID(),
                    name: "Foo",
                    color: Constants.selectionColors[8],
                    emoji: Constants.emojis[3],
                    schedule: [WeekDay.monday, WeekDay.tuesday, WeekDay.wednesday, WeekDay.thursday, WeekDay.friday, WeekDay.saturday, WeekDay.sunday],
                    date: nil
                )
            ]
        ),
        TrackerCategory(
            title: "Quux",
            trackers: [
                Tracker(
                    id: UUID(),
                    name: "Foo",
                    color: Constants.selectionColors[10],
                    emoji: Constants.emojis[11],
                    schedule: nil,
                    date: Date()
                ),
                Tracker(
                    id: UUID(),
                    name: "Bar",
                    color: Constants.selectionColors[7],
                    emoji: Constants.emojis[5],
                    schedule: [WeekDay.monday],
                    date: nil
                ),
                Tracker(
                    id: UUID(),
                    name: "Baz",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[12],
                    schedule: nil,
                    date: Date()
                )
            ]
        )
    ]
}
