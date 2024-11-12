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
                    title: "Special15",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[0],
                    schedule: Schedule(type: .special(Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 15))!))
                ),
                Tracker(
                    id: UUID(),
                    title: "Bar",
                    color: Constants.selectionColors[5],
                    emoji: Constants.emojis[9],
                    schedule: Schedule(type: .regular([WeekDay.friday, WeekDay.saturday]))
                ),
                Tracker(
                    id: UUID(),
                    title: "Special14",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[0],
                    schedule: Schedule(type: .special(Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 14))!))
                ),
                Tracker(
                    id: UUID(),
                    title: "Special13",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[0],
                    schedule: Schedule(type: .special(Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 13))!))
                ),
            ]
        ),
        TrackerCategory(
            title: "Bar",
            trackers: [
                Tracker(
                    id: UUID(),
                    title: "Quux",
                    color: Constants.selectionColors[2],
                    emoji: Constants.emojis[1],
                    schedule: Schedule(type: .regular([WeekDay.tuesday, WeekDay.friday, WeekDay.saturday]))
                ),
                Tracker(
                    id: UUID(),
                    title: "Foo",
                    color: Constants.selectionColors[8],
                    emoji: Constants.emojis[3],
                    schedule: Schedule(type: .regular([WeekDay.monday, WeekDay.tuesday, WeekDay.wednesday, WeekDay.thursday, WeekDay.friday, WeekDay.saturday]))
                ),
                Tracker(
                    id: UUID(),
                    title: "Quuuuuuuuuuuux",
                    color: Constants.selectionColors[2],
                    emoji: Constants.emojis[1],
                    schedule: Schedule(type: .regular([WeekDay.tuesday, WeekDay.friday, WeekDay.saturday]))
                ),
                Tracker(
                    id: UUID(),
                    title: "Special12",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[0],
                    schedule: Schedule(type: .special(Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 12))!))
                ),
            ]
        ),
        TrackerCategory(
            title: "Quux",
            trackers: [
                Tracker(
                    id: UUID(),
                    title: "Foo",
                    color: Constants.selectionColors[10],
                    emoji: Constants.emojis[11],
                    schedule: Schedule(type: .regular([WeekDay.monday]))
                ),
                Tracker(
                    id: UUID(),
                    title: "Special11",
                    color: Constants.selectionColors[7],
                    emoji: Constants.emojis[5],
                    schedule: Schedule(type: .special(Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 11))!))
                ),
                Tracker(
                    id: UUID(),
                    title: "Special10",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[12],
                    schedule: Schedule(type: .special(Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 10))!))
                ),
                Tracker(
                    id: UUID(),
                    title: "Quuuux",
                    color: Constants.selectionColors[2],
                    emoji: Constants.emojis[1],
                    schedule: Schedule(type: .regular([WeekDay.tuesday, WeekDay.friday, WeekDay.saturday]))
                ),
                Tracker(
                    id: UUID(),
                    title: "Special9",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[0],
                    schedule: Schedule(type: .special(Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 9))!))
                ),
                Tracker(
                    id: UUID(),
                    title: "Special8",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[0],
                    schedule: Schedule(type: .special(Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 8))!))
                ),
            ]
        ),
        TrackerCategory(
            title: "Quuux",
            trackers: [
                Tracker(
                    id: UUID(),
                    title: "Foo",
                    color: Constants.selectionColors[10],
                    emoji: Constants.emojis[11],
                    schedule: Schedule(type: .regular([WeekDay.monday]))
                ),
                Tracker(
                    id: UUID(),
                    title: "Special7",
                    color: Constants.selectionColors[7],
                    emoji: Constants.emojis[5],
                    schedule: Schedule(type: .special(Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 7))!))
                ),
                Tracker(
                    id: UUID(),
                    title: "Special6",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[12],
                    schedule: Schedule(type: .special(Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 6))!))
                ),
                Tracker(
                    id: UUID(),
                    title: "Quuuuuux",
                    color: Constants.selectionColors[2],
                    emoji: Constants.emojis[1],
                    schedule: Schedule(type: .regular([WeekDay.tuesday, WeekDay.friday, WeekDay.saturday]))
                ),
                Tracker(
                    id: UUID(),
                    title: "Special5",
                    color: Constants.selectionColors[4],
                    emoji: Constants.emojis[0],
                    schedule: Schedule(type: .special(Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 5))!))
                ),
            ]
        )
    ]
}
