import Foundation

public protocol ApplyStatisticsInsightUseCaseProtocol: Sendable {
    func execute(_ insight: StatisticsInsight) async throws
}

enum ApplyStatisticsInsightError: Error, Equatable {
    case trackerNotFound
    case scheduleChanged
}

struct ApplyStatisticsInsightUseCase: ApplyStatisticsInsightUseCaseProtocol {
    private let fetchTracker: @Sendable (UUID) async throws -> Tracker?
    private let updateTracker: @Sendable (Tracker) async throws -> Void
    private let now: @Sendable () -> Date

    init(
        trackerRepository: some TrackerRepositoryProtocol,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.fetchTracker = { id in
            try await trackerRepository.getTrackers(id: id).first
        }
        self.updateTracker = trackerRepository.updateTracker
        self.now = now
    }

    init(
        fetchTracker: @escaping @Sendable (UUID) async throws -> Tracker?,
        updateTracker: @escaping @Sendable (Tracker) async throws -> Void,
        now: @escaping @Sendable () -> Date
    ) {
        self.fetchTracker = fetchTracker
        self.updateTracker = updateTracker
        self.now = now
    }

    func execute(_ insight: StatisticsInsight) async throws {
        guard let tracker = try await fetchTracker(insight.trackerID) else {
            throw ApplyStatisticsInsightError.trackerNotFound
        }

        let source: WeekDay
        let destination: WeekDay
        switch insight.proposedAction {
        case .moveSchedule(let from, let to):
            source = from
            destination = to
        }

        guard tracker.weekDays.contains(source), !tracker.weekDays.contains(destination) else {
            throw ApplyStatisticsInsightError.scheduleChanged
        }

        try await updateTracker(tracker.movingSchedule(from: source, to: destination, at: now()))
    }
}
