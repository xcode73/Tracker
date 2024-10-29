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
                    title: "Special21",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[0],
                    schedule: nil,
                    date: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 21))
                ),
                Tracker(
                    id: UUID(),
                    title: "Bar",
                    color: Constants.selectionColors[5],
                    emoji: Constants.emojis[9],
                    schedule: [WeekDay.friday, WeekDay.saturday],
                    date: nil
                ),
                Tracker(
                    id: UUID(),
                    title: "Special22",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[0],
                    schedule: nil,
                    date: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 22))
                ),
                Tracker(
                    id: UUID(),
                    title: "Special23",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[0],
                    schedule: nil,
                    date: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 23))
                ),
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
                    date: nil
                ),
                Tracker(
                    id: UUID(),
                    title: "Foo",
                    color: Constants.selectionColors[8],
                    emoji: Constants.emojis[3],
                    schedule: [WeekDay.monday, WeekDay.tuesday, WeekDay.wednesday, WeekDay.thursday, WeekDay.friday, WeekDay.saturday],
                    date: nil
                ),
                Tracker(
                    id: UUID(),
                    title: "Quuuuuuuuuuuux",
                    color: Constants.selectionColors[2],
                    emoji: Constants.emojis[1],
                    schedule: [WeekDay.tuesday, WeekDay.friday, WeekDay.saturday],
                    date: nil
                ),
                Tracker(
                    id: UUID(),
                    title: "Special24",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[0],
                    schedule: nil,
                    date: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 24))
                ),
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
                    date: nil
                ),
                Tracker(
                    id: UUID(),
                    title: "Bar",
                    color: Constants.selectionColors[7],
                    emoji: Constants.emojis[5],
                    schedule: nil,
                    date: Date()
                ),
                Tracker(
                    id: UUID(),
                    title: "Baz",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[12],
                    schedule: nil,
                    date: Date()
                ),
                Tracker(
                    id: UUID(),
                    title: "Quuuux",
                    color: Constants.selectionColors[2],
                    emoji: Constants.emojis[1],
                    schedule: [WeekDay.tuesday, WeekDay.friday, WeekDay.saturday],
                    date: nil
                ),
                Tracker(
                    id: UUID(),
                    title: "Special25",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[0],
                    schedule: nil,
                    date: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 25))
                ),
                Tracker(
                    id: UUID(),
                    title: "Special26",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[0],
                    schedule: nil,
                    date: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 26))
                ),
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
                    date: nil
                ),
                Tracker(
                    id: UUID(),
                    title: "Bar",
                    color: Constants.selectionColors[7],
                    emoji: Constants.emojis[5],
                    schedule: nil,
                    date: Date()
                ),
                Tracker(
                    id: UUID(),
                    title: "Baz",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[12],
                    schedule: nil,
                    date: Date()
                ),
                Tracker(
                    id: UUID(),
                    title: "Quuuuuux",
                    color: Constants.selectionColors[2],
                    emoji: Constants.emojis[1],
                    schedule: [WeekDay.tuesday, WeekDay.friday, WeekDay.saturday],
                    date: nil
                ),
                Tracker(
                    id: UUID(),
                    title: "Special27",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[0],
                    schedule: nil,
                    date: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 27))
                ),
            ]
        )
    ]
}
