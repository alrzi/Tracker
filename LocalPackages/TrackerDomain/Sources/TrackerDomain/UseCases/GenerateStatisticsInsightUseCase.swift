import Foundation
import Utils

public protocol StatisticsInsightGenerating: Sendable {
    var isAvailable: Bool { get async }
    func generateCopy(for candidate: StatisticsInsightCandidate) async throws -> StatisticsInsightCopy
}

public protocol StatisticsInsightHistoryProviding: Sendable {
    func fetchTrackers() async throws -> [Tracker]
    func fetchRecords() async throws -> [TrackerRecord]
}

public protocol GenerateStatisticsInsightUseCaseProtocol: Sendable {
    func execute() async throws -> StatisticsInsight?
}

struct GenerateStatisticsInsightUseCase: GenerateStatisticsInsightUseCaseProtocol {
    private let historyProvider: any StatisticsInsightHistoryProviding
    private let generator: any StatisticsInsightGenerating
    private let calendar: Calendar
    private let now: @Sendable () -> Date
    private let analysisDayCount: Int
    private let minimumObservationCount: Int

    init(
        historyProvider: some StatisticsInsightHistoryProviding,
        generator: some StatisticsInsightGenerating,
        calendar: Calendar = .current,
        analysisDayCount: Int = 28,
        minimumObservationCount: Int = 4,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.historyProvider = historyProvider
        self.generator = generator
        self.calendar = calendar
        self.analysisDayCount = analysisDayCount
        self.minimumObservationCount = minimumObservationCount
        self.now = now
    }

    func execute() async throws -> StatisticsInsight? {
        guard await generator.isAvailable else {
            return nil
        }

        async let trackersRequest = historyProvider.fetchTrackers()
        async let recordsRequest = historyProvider.fetchRecords()

        let (trackers, records) = try await (trackersRequest, recordsRequest)

        guard let candidate = makeCandidate(trackers: trackers, records: records) else {
            return nil
        }

        let copy = try await generator.generateCopy(for: candidate)

        return StatisticsInsight(
            trackerID: candidate.trackerID,
            trackerName: candidate.trackerName,
            title: copy.title,
            explanation: copy.explanation,
            evidence: StatisticsInsightEvidence(
                observedWeekDay: candidate.observedWeekDay,
                completedCount: candidate.completedCount,
                scheduledCount: candidate.scheduledCount
            ),
            proposedAction: .moveSchedule(
                from: candidate.observedWeekDay,
                to: candidate.suggestedWeekDay
            )
        )
    }
}

private extension GenerateStatisticsInsightUseCase {
    struct CompletionKey: Hashable {
        let trackerID: UUID
        let date: Date
    }

    struct DayPerformance {
        var completed = 0
        var scheduled = 0

        var rate: Double {
            guard scheduled > 0 else {
                return 0
            }

            return Double(completed) / Double(scheduled)
        }
    }

    func makeCandidate(trackers: [Tracker], records: [TrackerRecord]) -> StatisticsInsightCandidate? {
        let today = calendar.startOfDay(for: now())
        let windowStart = today.advanced(by: -analysisDayCount, .day, calendar: calendar)
        let yesterday = today.advanced(by: -1, .day, calendar: calendar)

        let completions = Set(records.map {
            CompletionKey(trackerID: $0.id, date: calendar.startOfDay(for: $0.date))
        })
        var overallPerformance = Dictionary(
            uniqueKeysWithValues: WeekDay.allCases.map { ($0, DayPerformance()) }
        )
        var trackerPerformance: [UUID: [WeekDay: DayPerformance]] = [:]

        for tracker in trackers {
            let reliableStart = max(
                windowStart,
                calendar.startOfDay(for: tracker.createdAt),
                calendar.startOfDay(for: tracker.scheduleUpdatedAt)
            )
            guard reliableStart <= yesterday else { continue }

            var date = reliableStart
            while date <= yesterday {
                let weekDay = weekDay(for: date)
                if tracker.weekDays.contains(weekDay) {
                    let isCompleted = completions.contains(
                        CompletionKey(trackerID: tracker.id, date: date)
                    )
                    overallPerformance[weekDay, default: DayPerformance()].scheduled += 1
                    trackerPerformance[tracker.id, default: [:]][weekDay, default: DayPerformance()].scheduled += 1

                    if isCompleted {
                        overallPerformance[weekDay, default: DayPerformance()].completed += 1
                        trackerPerformance[tracker.id, default: [:]][weekDay, default: DayPerformance()].completed += 1
                    }
                }
                let nextDate = date.advanced(by: 1, .day, calendar: calendar)
                guard nextDate > date else { break }
                date = nextDate
            }
        }

        let sortedTrackers = trackers.sorted { $0.id.uuidString < $1.id.uuidString }
        for tracker in sortedTrackers {
            guard let performance = trackerPerformance[tracker.id] else { continue }

            let weakDay = performance
                .filter { $0.value.scheduled >= minimumObservationCount && $0.value.rate <= 0.25 }
                .sorted {
                    if $0.value.rate == $1.value.rate { return $0.key.rawValue < $1.key.rawValue }
                    return $0.value.rate < $1.value.rate
                }
                .first

            let alternative = overallPerformance
                .filter {
                    !tracker.weekDays.contains($0.key)
                        && $0.value.scheduled >= minimumObservationCount
                        && $0.value.rate >= 0.75
                }
                .sorted {
                    if $0.value.rate == $1.value.rate { return $0.key.rawValue < $1.key.rawValue }
                    return $0.value.rate > $1.value.rate
                }
                .first

            if let weakDay, let alternative {
                return StatisticsInsightCandidate(
                    trackerID: tracker.id,
                    trackerName: tracker.name,
                    observedWeekDay: weakDay.key,
                    completedCount: weakDay.value.completed,
                    scheduledCount: weakDay.value.scheduled,
                    suggestedWeekDay: alternative.key
                )
            }
        }

        return nil
    }

    func weekDay(for date: Date) -> WeekDay {
        switch calendar.component(.weekday, from: date) {
        case 1: .sunday
        case 2: .monday
        case 3: .tuesday
        case 4: .wednesday
        case 5: .thursday
        case 6: .friday
        default: .saturday
        }
    }
}
