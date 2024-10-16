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
            id: UUID(),
            title: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr",
            trackers: [
                Tracker(
                    id: UUID(),
                    title: "Lorem ipsum dolor sit amet, consetetur",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[0],
                    schedule: [WeekDay.tuesday],
                    isRegular: false
                ),
                Tracker(
                    id: UUID(),
                    title: "Bar",
                    color: Constants.selectionColors[5],
                    emoji: Constants.emojis[9],
                    schedule: [WeekDay.friday, WeekDay.saturday],
                    isRegular: true
                )
            ]
        ),
        TrackerCategory(
            id: UUID(),
            title: "Bar",
            trackers: [
                Tracker(
                    id: UUID(),
                    title: "Quux",
                    color: Constants.selectionColors[2],
                    emoji: Constants.emojis[1],
                    schedule: [WeekDay.tuesday, WeekDay.friday, WeekDay.saturday],
                    isRegular: true
                ),
                Tracker(
                    id: UUID(),
                    title: "Foo",
                    color: Constants.selectionColors[8],
                    emoji: Constants.emojis[3],
                    schedule: [WeekDay.monday, WeekDay.tuesday, WeekDay.wednesday, WeekDay.thursday, WeekDay.friday, WeekDay.saturday],
                    isRegular: true
                )
            ]
        ),
        TrackerCategory(
            id: UUID(),
            title: "Quux",
            trackers: [
                Tracker(
                    id: UUID(),
                    title: "Foo",
                    color: Constants.selectionColors[10],
                    emoji: Constants.emojis[11],
                    schedule: [WeekDay.monday],
                    isRegular: true
                ),
                Tracker(
                    id: UUID(),
                    title: "Bar",
                    color: Constants.selectionColors[7],
                    emoji: Constants.emojis[5],
                    schedule: [WeekDay.monday],
                    isRegular: false
                ),
                Tracker(
                    id: UUID(),
                    title: "Baz",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[12],
                    schedule: [WeekDay.friday],
                    isRegular: false
                )
            ]
        ),
        TrackerCategory(
            id: UUID(),
            title: "Quuux",
            trackers: [
                Tracker(
                    id: UUID(),
                    title: "Foo",
                    color: Constants.selectionColors[10],
                    emoji: Constants.emojis[11],
                    schedule: [WeekDay.monday],
                    isRegular: true
                ),
                Tracker(
                    id: UUID(),
                    title: "Bar",
                    color: Constants.selectionColors[7],
                    emoji: Constants.emojis[5],
                    schedule: [WeekDay.monday],
                    isRegular: false
                ),
                Tracker(
                    id: UUID(),
                    title: "Baz",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[12],
                    schedule: [WeekDay.friday],
                    isRegular: false
                )
            ]
        )
    ]
}
