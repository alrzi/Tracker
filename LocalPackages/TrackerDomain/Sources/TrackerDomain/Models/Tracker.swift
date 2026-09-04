import Foundation

public struct Tracker: Hashable, Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let emoji: String
    public let color: String
    public let weekDays: Set<WeekDay>
    public let isPinned: Bool
    public let trackedDays: Int
    public let sectionId: UUID
    public let isCompleted: Bool
    public let notificationInformation: TrackerNotificationInformation?

    public init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        color: String,
        schedule: Set<WeekDay>,
        isPinned: Bool = false,
        trackedDays: Int = .zero,
        sectionId: UUID,
        isCompleted: Bool = false,
        notificationInformation: TrackerNotificationInformation?,
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.color = color
        self.weekDays = schedule
        self.isPinned = isPinned
        self.trackedDays = trackedDays
        self.sectionId = sectionId
        self.isCompleted = isCompleted
        self.notificationInformation = notificationInformation
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
            sectionId: sectionId,
            notificationInformation: notificationInformation,
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
            sectionId: sectionId,
            isCompleted: isCompleted,
            notificationInformation: notificationInformation,
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
            sectionId: sectionId,
            isCompleted: isCompleted,
            notificationInformation: notificationInformation,
        )
    }
}
