import Foundation

struct Tracker: Hashable, Identifiable {
    let id: UUID
    let name: String
    let emoji: String
    let color: String
    let weekDays: Set<Int>
    let isPinned: Bool
    let kind: TrackerKind
    let trackedDays: Int
    
    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        color: String,
        schedule: Set<Int>,
        isPinned: Bool = false,
        kind: TrackerKind,
        trackedDays: Int
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.color = color
        self.weekDays = schedule
        self.isPinned = isPinned
        self.kind = kind
        self.trackedDays = trackedDays
    }
}

extension Tracker {
    func toggleIsPinned() -> Self {
        Tracker(
            id: id,
            name: name,
            emoji: emoji,
            color: color,
            schedule: weekDays,
            isPinned: !isPinned,
            kind: kind, 
            trackedDays: trackedDays
        )
    }
    
    func updated(trackedDays: Int) -> Self {
        Tracker(
            id: id,
            name: name,
            emoji: emoji,
            color: color,
            schedule: weekDays,
            isPinned: isPinned,
            kind: kind,
            trackedDays: trackedDays
        )
    }
}

let work = [
    Tracker(
        name: "Проверить пулРеквесты",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: WeekDay.allDaysOfWeek,
        kind: .occasional,
        trackedDays: 0
    ),
    Tracker(
        name: "Задать вопросы",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: WeekDay.allDaysOfWeek,
        kind: .occasional,
        trackedDays: 0
    ),
]

let life = [
    Tracker(
        name: "Погулять в пакре",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: WeekDay.allDaysOfWeek,
        kind: .occasional,
        trackedDays: 0
    ),
    Tracker(
        name: "Поговорить с девушкой незнакомой",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: WeekDay.allDaysOfWeek,
        kind: .occasional,
        trackedDays: 0
    )
]

let cooking = [
    Tracker(
        name: "Приготовить что то вкусненькое",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [1],
        kind: .habit,
        trackedDays: 0
    )
]

let movie = [
    Tracker(
        name: "Посмотреть фильм или мультик",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [1],
        kind: .habit,
        trackedDays: 0
    )
]

let socialization = [
    Tracker(
        name: "Сходить в антикафе",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [2],
        kind: .habit,
        trackedDays: 0
    )
]

let relations = [
    Tracker(
        name: "Позвонить родственникам",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [2],
        kind: .habit,
        trackedDays: 0
    )
]

let adventure = [
    Tracker(
        name: "Погулять в новом месте",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [3],
        kind: .habit,
        trackedDays: 0
    )
]

let books = [
    Tracker(
        name: "Почитать книгу",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [4],
        kind: .habit,
        trackedDays: 0
    )
]

let hobbie = [
    Tracker(
        name: "Порефакторить проект",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [5],
        kind: .habit,
        trackedDays: 0
    )
]

let englishClub = [
    Tracker(
        name: "Сходить на английский",
        emoji: RandomEmojiService.emoji,
        color: RandomHexColorService.randomHexString,
        schedule: [6],
//        isPinned: true, 
        kind: .habit,
        trackedDays: 0
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
