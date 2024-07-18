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

extension Tracker {
    init(coreData: TrackerObject) {
        self.id = coreData.id
        self.name = coreData.name
        self.emoji = coreData.emoji
        self.color = coreData.color
        self.isAttached = coreData.isPinned
        self.kind = coreData.kind
        self.schedule = Set.fromString(coreData.weekDays) ?? .init()
    }
}


let mockSport = [
    Tracker(name: "Run 1km", emoji: "🥇", color: "#FD4C49", schedule: [1,3,5], kind: .habit),
    Tracker(name: "Swim 1km", emoji: "🏊‍♀️", color: "#FF881E", schedule: [2,4,6], kind: .habit),
    Tracker(name: "Sky 1km", emoji: "⛷️", color: "#35347C", schedule: [7], kind: .habit),
    Tracker(name: "Cycle", emoji: "🚴‍♀️", color: "##33CF69", schedule: [7], kind: .habit),
    Tracker(name: "Sky 1km", emoji: "⛷️", color: "#35347C", schedule: [7], kind: .habit),
    Tracker(name: "Cycle", emoji: "🚴‍♀️", color: "##33CF69", schedule: [7], kind: .habit),
    Tracker(name: "Sky 1km", emoji: "⛷️", color: "#35347C", schedule: [7], kind: .habit),
    Tracker(name: "Cycle", emoji: "🚴‍♀️", color: "##33CF69", schedule: [7], kind: .habit),
]

//let mockReading = [
//    Tracker(name: "Swift in depth", emoji: "🚀", color: "#FD4C49", schedule: WeekDay.allDaysOfWeek, kind: .ocasional),
//    Tracker(name: "Swift apprentice", emoji: "🚁", color: "#8D72E6", schedule: [2,4,6], kind: .habit),
//    Tracker(name: "Any book", emoji: "⛵️", color: "#FF99CC", schedule: [7], kind: .habit),
//    Tracker(name: "Cycle", emoji: "🗿", color: "#F6C48B", schedule: [7], kind: .habit),
//    Tracker(name: "Any book", emoji: "⛵️", color: "#FF99CC", schedule: [7], kind: .habit),
//    Tracker(name: "Cycle", emoji: "🗿", color: "#F6C48B", schedule: [7], kind: .habit),
//]

//let mockCategories = [
//TrackerCategory(header: "Sport", trackers: mockSport, isLastSelected: false),
//TrackerCategory(header: "Reading", trackers: mockReading, isLastSelected: false)
//]
