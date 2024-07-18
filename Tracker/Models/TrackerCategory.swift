import Foundation

struct TrackerCategory: Hashable {
    let id: UUID
    let header: String
    let trackers: [Tracker]
    
    init(
        id: UUID = UUID(),
        header: String,
        trackers: [Tracker]
    ) {
        self.id = id
        self.header = header
        self.trackers = trackers        
    }
}

extension TrackerCategory {
    init(coreData: CategoryObject) {
        self.id = coreData.id
        self.header = coreData.title
        
        let trackerCoreDatas = coreData.trackers?.array as? [TrackerObject] ?? []
        self.trackers = trackerCoreDatas.map { Tracker(coreData: $0) }
    }
}

struct TrackerSection: Hashable, Identifiable {
    let id: UUID
    let header: String
    let trackers: [Tracker]
    
    
    init(
        id: UUID = UUID(),
        header: String,
        trackers: [Tracker]
    ) {
        self.id = id
        self.header = header
        self.trackers = trackers
    }
}

struct Traccker: Hashable {
    enum Kind: String {
        case habit
        case ocasional
    }

    let id: UUID
    let kind: Kind
    let name: String
    let emoji: String
    let color: String
    let weekDays: Set<WeekDay>
    let isPinned: Bool
    
    
    init(
        id: UUID = UUID(),
        kind: Kind,
        name: String,
        emoji: String,
        color: String,
        weekDays: Set<WeekDay>,
        isPinned: Bool
    ) {
        self.id = id
        self.kind = kind
        self.name = name
        self.emoji = emoji
        self.color = color
        self.weekDays = weekDays
        self.isPinned = isPinned        
    }
}
