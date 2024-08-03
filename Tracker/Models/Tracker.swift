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

let mockSport = [
    Tracker(
        name: "Run 1km",
        emoji: "🥇",
        color: "#FD4C49",
        schedule: [1,3,5],
        kind: .habit,
        trackedDays: 2
    ),
    Tracker(
        name: "Swim 1km",
        emoji: "🏊‍♀️",
        color: "#Fd881E",
        schedule: [2,4,6],
        kind: .habit,
        trackedDays: 14
    )
]

let mockReading = [
    Tracker(
        name: "Swift in depth",
        emoji: "🚀",
        color: "#FD4C49",
        schedule: WeekDay.allDaysOfWeek,
        kind: .occasional,
        trackedDays: 4
    ),
    Tracker(
        name: "Swift apprentice",
        emoji: "🚁",
        color: "#8g72E6",
        schedule: [2,4,6],
        kind: .habit,
        trackedDays: 5
    )
]

let mockCategories = [
    TrackerSection(title: "Sport", trackers: mockSport),
    TrackerSection(title: "Reading", trackers: mockReading)
]
