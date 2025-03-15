//
//  File.swift
//  Tracker
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Foundation
import TrackerDomain

func createSectionsWithTrackers(sectionCount: Int, trackerCount: Int) -> ([TrackerSection], [TrackerRecord]) {
    var sections: [TrackerSection] = []
    var records: [TrackerRecord] = []
        
    for sectionIndex in 0..<sectionCount {
        var trackers: [Tracker] = []
        
        let sectionID: UUID = .init()
        
        for trackerIndex in 0..<trackerCount {
            let id = UUID()
            let tracker = Tracker(
                id: id,
                name: "Section \(sectionIndex) - Item \(trackerIndex)",
                emoji: RandomEmojiService.emoji,
                color: RandomHexColorService.randomHexString,
                schedule: WeekDay.allDaysOfWeek,
                isPinned: false,
                kind: .habit,
                trackedDays: 0,
                categoryId: sectionID
            )
            trackers.append(tracker)
            
            if trackerIndex.isMultiple(of: 2) {
                records.append(.init(id: id, date: .now))
            }
        }
        
        let section = TrackerSection(
            id: sectionID,
            title: "Section \(sectionIndex)",
            trackers: trackers
        )
        sections.append(section)
    }
    
    return (sections, records)
}
