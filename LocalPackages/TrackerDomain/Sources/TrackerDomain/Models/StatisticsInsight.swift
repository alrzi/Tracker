import Foundation

public struct StatisticsInsight: Sendable, Equatable {
    public let trackerID: UUID
    public let trackerName: String
    public let title: String
    public let explanation: String
    public let evidence: StatisticsInsightEvidence
    public let proposedAction: StatisticsInsightAction

    public init(
        trackerID: UUID,
        trackerName: String,
        title: String,
        explanation: String,
        evidence: StatisticsInsightEvidence,
        proposedAction: StatisticsInsightAction
    ) {
        self.trackerID = trackerID
        self.trackerName = trackerName
        self.title = title
        self.explanation = explanation
        self.evidence = evidence
        self.proposedAction = proposedAction
    }
}

public struct StatisticsInsightEvidence: Sendable, Equatable {
    public let observedWeekDay: WeekDay
    public let completedCount: Int
    public let scheduledCount: Int

    public init(observedWeekDay: WeekDay, completedCount: Int, scheduledCount: Int) {
        self.observedWeekDay = observedWeekDay
        self.completedCount = completedCount
        self.scheduledCount = scheduledCount
    }
}

public enum StatisticsInsightAction: Sendable, Equatable {
    case moveSchedule(from: WeekDay, to: WeekDay)
}

public struct StatisticsInsightCandidate: Sendable, Equatable {
    public let trackerID: UUID
    public let trackerName: String
    public let observedWeekDay: WeekDay
    public let completedCount: Int
    public let scheduledCount: Int
    public let suggestedWeekDay: WeekDay

    public init(
        trackerID: UUID,
        trackerName: String,
        observedWeekDay: WeekDay,
        completedCount: Int,
        scheduledCount: Int,
        suggestedWeekDay: WeekDay
    ) {
        self.trackerID = trackerID
        self.trackerName = trackerName
        self.observedWeekDay = observedWeekDay
        self.completedCount = completedCount
        self.scheduledCount = scheduledCount
        self.suggestedWeekDay = suggestedWeekDay
    }
}

public struct StatisticsInsightCopy: Sendable, Equatable {
    public let title: String
    public let explanation: String

    public init(title: String, explanation: String) {
        self.title = title
        self.explanation = explanation
    }
}
