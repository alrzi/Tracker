//
//  File.swift
//  Tracker
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Foundation
import TrackerDomain

#if DEBUG
private let statisticsInsightWorkoutID = UUID(uuidString: "10000000-0000-0000-0000-000000000002")!
private let statisticsInsightWalkID = UUID(uuidString: "10000000-0000-0000-0000-000000000003")!

struct TrackerMockData {
    let sections: [TrackerSection]
    let records: [TrackerRecord]
}

func createSectionsWithTrackers(
    calendar: Calendar = .current,
    now: Date = Date()
) -> TrackerMockData {
    let sportSectionID = UUID()
    let workoutID = statisticsInsightWorkoutID
    let walkID = statisticsInsightWalkID
    let today = calendar.startOfDay(for: now)
    let historyStart = calendar.date(byAdding: .day, value: -35, to: today) ?? today

    let sportSection = TrackerSection(
        id: sportSectionID,
        title: "Спорт",
        trackers: [
            Tracker(
                id: workoutID,
                name: "Тренировка",
                emoji: "🏋️‍♀️",
                color: "#45B7D1",
                schedule: [.friday],
                sectionId: sportSectionID,
                notificationInformation: nil,
                createdAt: historyStart,
                scheduleUpdatedAt: historyStart
            ),
            Tracker(
                id: walkID,
                name: "Прогулка",
                emoji: "🚶",
                color: "#4ECDC4",
                schedule: [.saturday],
                sectionId: sportSectionID,
                notificationInformation: nil,
                createdAt: historyStart,
                scheduleUpdatedAt: historyStart
            ),
            Tracker(
                name: "Бег",
                emoji: "🏃‍♂️",
                color: "#FF6B6B",
                schedule: [.monday, .wednesday],
                sectionId: sportSectionID,
                notificationInformation: nil,
                createdAt: historyStart,
                scheduleUpdatedAt: historyStart
            ),
        ]
    )

    let sections = [
        sportSection,
        makeSection(title: "Учёба", trackers: [
            ("Swift", "📱", "#5B8DEF"),
            ("Чтение", "📖", "#9B59B6"),
            ("Английский", "🗣️", "#F5A623"),
        ]),
        makeSection(title: "Здоровье", trackers: [
            ("Выпить воду", "💧", "#3498DB"),
            ("Медитация", "🧘", "#2ECC71"),
            ("Сон до 23:00", "😴", "#34495E"),
        ]),
    ]

    let records = previousOccurrences(
        of: .saturday,
        count: 4,
        before: today,
        calendar: calendar
    )
    .map { TrackerRecord(id: walkID, date: $0) }

    return TrackerMockData(sections: sections, records: records)
}

private func previousOccurrences(
    of weekDay: WeekDay,
    count: Int,
    before date: Date,
    calendar: Calendar
) -> [Date] {
    guard var cursor = calendar.date(byAdding: .day, value: -1, to: date) else { return [] }

    var dates: [Date] = []
    while dates.count < count {
        if calendar.component(.weekday, from: cursor) == weekDay.systemRawValue {
            dates.append(cursor)
        }
        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: cursor) else {
            break
        }
        cursor = previousDate
    }
    return dates
}

private func makeSection(
    title: String,
    trackers: [(name: String, emoji: String, color: String)]
) -> TrackerSection {
    let sectionID = UUID()

    return TrackerSection(
        id: sectionID,
        title: title,
        trackers: trackers.map {
            Tracker(
                name: $0.name,
                emoji: $0.emoji,
                color: $0.color,
                schedule: Set(WeekDay.allCases),
                sectionId: sectionID,
                notificationInformation: nil
            )
        }
    )
}

func createMultipleTrackerSections(
    numSections: Int,
    numTrackersPerSection: Int
) -> [TrackerSection] {
    var sections: [TrackerSection] = []
    
    for sectionIndex in 1...numSections {
        let sectionId = UUID()
        var trackers: [Tracker] = []
        
        for trackerIndex in 1...numTrackersPerSection {
            let tracker = Tracker(
                name: "Tracker \(trackerIndex) in Section \(sectionIndex)",
                emoji: getRandomEmoji(),
                color: getRandomHexColor(),
                schedule: getRandomSchedule(),
                sectionId: sectionId,
                notificationInformation: nil
            )
            trackers.append(tracker)
        }
        
        let section = TrackerSection(
            id: sectionId,
            title: "Section \(sectionIndex)",
            trackers: trackers
        )
        
        sections.append(section)
    }
    
    return sections
}

func getRandomEmoji() -> String {
    let emojis = ["🏋️‍♀️", "📖", "🎨", "🏃‍♂️", "🤸‍♀️"]
    return emojis.randomElement() ?? "😊"
}

func getRandomHexColor() -> String {
    let hexChars = "0123456789abcdef"
    var hexColor = "#"
    for _ in 1...6 {
        hexColor += String(hexChars.randomElement()!)
    }
    return hexColor
}

func getRandomSchedule() -> Set<WeekDay> {
    .init([WeekDay.allCases.randomElement()!])
}
#endif
