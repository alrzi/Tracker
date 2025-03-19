//
//  File.swift
//  Tracker
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Foundation
import TrackerDomain

func createSectionsWithTrackers(sectionCount: Int, trackerCount: Int) -> [TrackerSection] {
    var sections: [TrackerSection] = []
        
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
                schedule: [0,1,2,3,4,5,6],
                isPinned: false,
                kind: .habit,
                trackedDays: 0,
                categoryId: sectionID
            )
            trackers.append(tracker)
            print("trackerID", id)
        }
        
        let section = TrackerSection(
            id: sectionID,
            title: "Section \(sectionIndex)",
            trackers: trackers
        )
        sections.append(section)
        print("sectionID", sectionID)
    }
    
    return sections
}
