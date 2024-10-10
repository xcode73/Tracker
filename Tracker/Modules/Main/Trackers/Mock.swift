//
//  Mock.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 06.10.2024.
//

import Foundation

enum Mock {
    static let categories: [TrackerCategory] = [
        TrackerCategory(
            title: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr",
            trackers: [
                Tracker(
                    id: UUID(),
                    name: "Lorem ipsum dolor sit amet, consetetur",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[0],
                    schedule: [WeekDay.tuesday],
                    daysCompleted: 1
                ),
                Tracker(
                    id: UUID(),
                    name: "Bar",
                    color: Constants.selectionColors[5],
                    emoji: Constants.emojis[9],
                    schedule: [WeekDay.friday, WeekDay.saturday],
                    daysCompleted: 0
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
                    schedule: [WeekDay.tuesday, WeekDay.friday, WeekDay.saturday],
                    daysCompleted: 0
                ),
                Tracker(
                    id: UUID(),
                    name: "Foo",
                    color: Constants.selectionColors[8],
                    emoji: Constants.emojis[3],
                    schedule: [WeekDay.monday, WeekDay.tuesday, WeekDay.wednesday, WeekDay.thursday, WeekDay.friday, WeekDay.saturday],
                    daysCompleted: 0
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
                    schedule: [WeekDay.monday],
                    daysCompleted: 0
                ),
                Tracker(
                    id: UUID(),
                    name: "Bar",
                    color: Constants.selectionColors[7],
                    emoji: Constants.emojis[5],
                    schedule: [WeekDay.monday],
                    daysCompleted: 0
                ),
                Tracker(
                    id: UUID(),
                    name: "Baz",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[12],
                    schedule: [WeekDay.friday],
                    daysCompleted: 0
                )
            ]
        )
    ]
}
