import Foundation

public struct Tracker: Hashable, Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let emoji: String
    public let color: String
    public let weekDays: Set<Int>
    public let isPinned: Bool
    public let kind: Kind
    public let trackedDays: Int
    public let categoryId: UUID
    
    public init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        color: String,
        schedule: Set<Int>,
        isPinned: Bool,
        kind: Kind,
        trackedDays: Int,
        categoryId: UUID
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.color = color
        self.weekDays = schedule
        self.isPinned = isPinned
        self.kind = kind
        self.trackedDays = trackedDays
        self.categoryId = categoryId
    }
}

public extension Tracker {
    enum Kind: Sendable {
        case habit
        case occasional
    }
}

public extension Tracker {
    func toggleIsPinned() -> Self {
        Tracker(
            id: id,
            name: name,
            emoji: emoji,
            color: color,
            schedule: weekDays,
            isPinned: !isPinned,
            kind: kind, 
            trackedDays: trackedDays,
            categoryId: categoryId
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
            trackedDays: trackedDays,
            categoryId: categoryId
        )
    }
}
