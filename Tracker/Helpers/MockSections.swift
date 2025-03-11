//
//  File.swift
//  Tracker
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Foundation
import TrackerDomain

let work = [
    Tracker(
        name: "Проверить пулРеквесты",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: WeekDay.allDaysOfWeek,
        isPinned: false,
        kind: .occasional,
        trackedDays: 0,
        categoryId: .init()
    ),
    Tracker(
        name: "Задать вопросы",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: WeekDay.allDaysOfWeek,
        isPinned: false,
        kind: .occasional,
        trackedDays: 0,
        categoryId: .init()
    ),
]

let life = [
    Tracker(
        name: "Погулять в пакре",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: WeekDay.allDaysOfWeek,
        isPinned: false,
        kind: .occasional,
        trackedDays: 0,
        categoryId: .init()
    ),
    Tracker(
        name: "Поговорить с девушкой незнакомой",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: WeekDay.allDaysOfWeek,
        isPinned: true,
        kind: .occasional,
        trackedDays: 0,
        categoryId: .init()
    )
]

let cooking = [
    Tracker(
        name: "Приготовить что то вкусненькое",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [1],
        isPinned: true,
        kind: .habit,
        trackedDays: 0,
        categoryId: .init()
    )
]

let movie = [
    Tracker(
        name: "Посмотреть фильм или мультик",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,        
        schedule: [1],
        isPinned: true,
        kind: .habit,
        trackedDays: 0,
        categoryId: .init()
    )
]

let socialization = [
    Tracker(
        name: "Сходить в антикафе",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [2],
        isPinned: true,
        kind: .habit,
        trackedDays: 0,
        categoryId: .init()
    )
]

let relations = [
    Tracker(
        name: "Позвонить родственникам",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [2],
        isPinned: true,
        kind: .habit,
        trackedDays: 0,
        categoryId: .init()
    )
]

let adventure = [
    Tracker(
        name: "Погулять в новом месте",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [3],
        isPinned: false,
        kind: .habit,
        trackedDays: 0,
        categoryId: .init()
    )
]

let books = [
    Tracker(
        name: "Почитать книгу",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [4],
        isPinned: false,
        kind: .habit,
        trackedDays: 0,
        categoryId: .init()
    )
]

let hobbie = [
    Tracker(
        name: "Порефакторить проект",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [5],
        isPinned: false,
        kind: .habit,
        trackedDays: 0,
        categoryId: .init()
    )
]

let englishClub = [
    Tracker(
        name: "Сходить на английский",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [6],
        isPinned: true,
        kind: .habit,
        trackedDays: 0,
        categoryId: .init()
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
