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
        let schedule: Set<WeekDay> = [.friday]
        
        for trackerIndex in 0..<trackerCount {
            let id = UUID()
            let tracker = Tracker(
                id: id,
                name: "Section \(sectionIndex) - Item \(trackerIndex)",
                emoji: RandomEmojiService.emoji,
                color: RandomHexColorService.randomHexString,
                schedule: schedule,
                isPinned: false,
                trackedDays: 0,
                sectionId: sectionID
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

let work = [
    Tracker(
        name: "Проверить пулРеквесты",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: Set(WeekDay.allCases),
        isPinned: false,
        trackedDays: 0,
        sectionId: .init()
    ),
    Tracker(
        name: "Задать вопросы",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [.tuesday],
        isPinned: false,
        trackedDays: 0,
        sectionId: .init()
    ),
]

let life = [
    Tracker(
        name: "Погулять в пакре",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: Set(WeekDay.allCases),
        isPinned: false,
        trackedDays: 0,
        sectionId: .init()
    ),
    Tracker(
        name: "Поговорить с девушкой незнакомой",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: Set(WeekDay.allCases),
        isPinned: true,
        trackedDays: 0,
        sectionId: .init()
    )
]

let cooking = [
    Tracker(
        name: "Приготовить что то вкусненькое",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [.friday],
        isPinned: true,
        trackedDays: 0,
        sectionId: .init()
    )
]

let movie = [
    Tracker(
        name: "Посмотреть фильм или мультик",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [.wednesday, .friday, .sunday],
        isPinned: true,
        trackedDays: 0,
        sectionId: .init()
    )
]

let socialization = [
    Tracker(
        name: "Сходить в антикафе",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [.sunday],
        isPinned: true,
        trackedDays: 0,
        sectionId: .init()
    )
]

let relations = [
    Tracker(
        name: "Позвонить родственникам",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [.friday],
        isPinned: true,
        trackedDays: 0,
        sectionId: .init()
    )
]

let adventure = [
    Tracker(
        name: "Погулять в новом месте",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [.saturday],
        isPinned: false,
        trackedDays: 0,
        sectionId: .init()
    )
]

let books = [
    Tracker(
        name: "Почитать книгу",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: Set(WeekDay.allCases),
        isPinned: false,
        trackedDays: 0,
        sectionId: .init()
    )
]

let hobbie = [
    Tracker(
        name: "Порефакторить проект",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: Set(WeekDay.allCases),
        isPinned: false,
        trackedDays: 0,
        sectionId: .init()
    )
]

let englishClub = [
    Tracker(
        name: "Сходить на английский",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [.sunday],
        isPinned: true,
        trackedDays: 0,
        sectionId: .init()
    )
]

let mockTrackerSections = [
    TrackerSection(title: "Работа", trackers: work),
    TrackerSection(title: "Жизнь", trackers: life),
    TrackerSection(title: "Вкусная еда", trackers: cooking),
    TrackerSection(title: "Кинематограф", trackers: movie),
    TrackerSection(title: "Общение", trackers: socialization),
    TrackerSection(title: "Родственники", trackers: relations),
    TrackerSection(title: "Приключения", trackers: adventure),
    TrackerSection(title: "Книги", trackers: books),
    TrackerSection(title: "Хобби", trackers: hobbie),
    TrackerSection(title: "Английский клуб", trackers: englishClub),
]
