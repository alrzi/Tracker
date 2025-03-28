import Foundation

public struct Tracker: Hashable, Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let emoji: String
    public let color: String
    public let weekDays: Set<WeekDay>
    public let isPinned: Bool
    public let trackedDays: Int
    public let categoryId: UUID
    public let isCompleted: Bool
    
    public init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        color: String,
        schedule: Set<WeekDay>,
        isPinned: Bool = false,
        trackedDays: Int = .zero,
        categoryId: UUID,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.color = color
        self.weekDays = schedule
        self.isPinned = isPinned
        self.trackedDays = trackedDays
        self.categoryId = categoryId
        self.isCompleted = isCompleted
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
            trackedDays: trackedDays,
            categoryId: categoryId
        )
    }
    
    func with(isCompleted: Bool) -> Self {
        Tracker(
            id: id,
            name: name,
            emoji: emoji,
            color: color,
            schedule: weekDays,
            isPinned: isPinned,
            trackedDays: trackedDays,
            categoryId: categoryId,
            isCompleted: isCompleted
        )
    }
        
    func with(isCompleted: Bool, trackedDays: Int) -> Self {
        Tracker(
            id: id,
            name: name,
            emoji: emoji,
            color: color,
            schedule: weekDays,
            isPinned: isPinned,
            trackedDays: trackedDays,
            categoryId: categoryId,
            isCompleted: isCompleted
        )
    }
}
