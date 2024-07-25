import Foundation

struct Tracker: Hashable {
    let id: UUID
    let name: String
    let emoji: String
    let color: String
    let schedule: Set<Int>
    let isAttached: Bool
    let kind: TrackerKind
    
    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        color: String,
        schedule: Set<Int>,
        isAttached: Bool = false,
        kind: TrackerKind
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.color = color
        self.schedule = schedule
        self.isAttached = isAttached
        self.kind = kind
    }
}

let mockSport = [
    Tracker(name: "Run 1km", emoji: "🥇", color: "#FD4C49", schedule: [1,3,5], kind: .habit),
    Tracker(name: "Swim 1km", emoji: "🏊‍♀️", color: "#Fd881E", schedule: [2,4,6], kind: .habit)
]

let mockReading = [
    Tracker(name: "Swift in depth", emoji: "🚀", color: "#FD4C49", schedule: WeekDay.allDaysOfWeek, kind: .occasional),
    Tracker(name: "Swift apprentice", emoji: "🚁", color: "#8g72E6", schedule: [2,4,6], kind: .habit)
]

let mockCategories = [
    TrackerCategory(header: "Sport", trackers: mockSport),
    TrackerCategory(header: "Reading", trackers: mockReading)
]
