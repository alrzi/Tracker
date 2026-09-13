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
    public let createdAt: Date
    public let scheduleUpdatedAt: Date

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
        createdAt: Date = Date(),
        scheduleUpdatedAt: Date? = nil,
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
        self.createdAt = createdAt
        self.scheduleUpdatedAt = scheduleUpdatedAt ?? createdAt
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
            createdAt: createdAt,
            scheduleUpdatedAt: scheduleUpdatedAt,
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
            createdAt: createdAt,
            scheduleUpdatedAt: scheduleUpdatedAt,
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
            createdAt: createdAt,
            scheduleUpdatedAt: scheduleUpdatedAt,
        )
    }

    func with(sectionId: UUID) -> Self {
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
            createdAt: createdAt,
            scheduleUpdatedAt: scheduleUpdatedAt,
        )
    }

    func movingSchedule(from source: WeekDay, to destination: WeekDay, at date: Date = Date()) -> Self {
        var updatedWeekDays = weekDays
        updatedWeekDays.remove(source)
        updatedWeekDays.insert(destination)

        let updatedNotificationInformation = notificationInformation.map { information in
            var updatedSchedule = information.schedule
            if let sourceDetails = updatedSchedule.removeValue(forKey: source) {
                updatedSchedule[destination] = .init(
                    weekDay: destination,
                    isEnabled: sourceDetails.isEnabled,
                    time: sourceDetails.time
                )
            }

            return TrackerNotificationInformation(
                trackerId: information.trackerId,
                isGlobalEnabled: information.isGlobalEnabled,
                schedule: updatedSchedule
            )
        }

        return Tracker(
            id: id,
            name: name,
            emoji: emoji,
            color: color,
            schedule: updatedWeekDays,
            isPinned: isPinned,
            trackedDays: trackedDays,
            sectionId: sectionId,
            isCompleted: isCompleted,
            notificationInformation: updatedNotificationInformation,
            createdAt: createdAt,
            scheduleUpdatedAt: date
        )
    }
}
