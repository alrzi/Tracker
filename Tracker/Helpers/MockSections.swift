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
    createMultipleTrackerSections(numSections: 20, numTrackersPerSection: 10)
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
