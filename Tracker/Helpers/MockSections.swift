//
//  File.swift
//  Tracker
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Foundation
import TrackerDomain

#if DEBUG
func createSectionsWithTrackers() -> [TrackerSection] {
    [
        makeSection(title: "Спорт", trackers: [
            ("Бег", "🏃‍♂️", "#FF6B6B"),
            ("Зарядка", "🤸‍♀️", "#4ECDC4"),
            ("Тренировка", "🏋️‍♀️", "#45B7D1"),
        ]),
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
