import Foundation
import Testing
@testable import TrackerDomain

@Suite("GenerateStatisticsInsightUseCase")
struct GenerateStatisticsInsightUseCaseTests {
    private let calendar = Calendar(identifier: .iso8601)
    private let now = Date(timeIntervalSince1970: 1_757_930_400) // 2025-09-15 09:00:00 UTC
    private let problemTrackerID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    private let referenceTrackerID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!

    @Test("returns no insight when the system model is unavailable")
    func unavailableModel() async throws {
        let generator = GeneratorSpy(isAvailable: false)
        let history = HistoryProviderSpy(trackers: [], records: [])
        let useCase = makeUseCase(history: history, generator: generator)

        let insight = try await useCase.execute()

        #expect(insight == nil)
        #expect(await history.fetchCount == 0)
        #expect(await generator.receivedCandidates.isEmpty)
    }

    @Test("builds evidence from reliable history and asks the generator only for copy")
    func generatesInsightFromReliableHistory() async throws {
        let generator = GeneratorSpy(
            isAvailable: true,
            copy: StatisticsInsightCopy(
                title: "Перенеси тренировку",
                explanation: "По пятницам привычка регулярно пропускается."
            )
        )
        let history = HistoryProviderSpy(
            trackers: [problemTracker(), referenceTracker()],
            records: [
                record(referenceTrackerID, "2025-08-23"),
                record(referenceTrackerID, "2025-08-30"),
                record(referenceTrackerID, "2025-09-06"),
                record(referenceTrackerID, "2025-09-13"),
                record(problemTrackerID, "2025-08-22")
            ]
        )
        let useCase = makeUseCase(history: history, generator: generator)

        let insight = try #require(try await useCase.execute())

        #expect(insight.trackerID == problemTrackerID)
        #expect(insight.trackerName == "Тренировка")
        #expect(insight.evidence == StatisticsInsightEvidence(
            observedWeekDay: .friday,
            completedCount: 1,
            scheduledCount: 4
        ))
        #expect(insight.proposedAction == .moveSchedule(from: .friday, to: .saturday))
        #expect(insight.title == "Перенеси тренировку")

        let candidate = try #require(await generator.receivedCandidates.first)
        #expect(candidate.trackerName == "Тренировка")
        #expect(candidate.completedCount == 1)
        #expect(candidate.scheduledCount == 4)
        #expect(candidate.suggestedWeekDay == .saturday)
    }

    @Test("does not treat dates before the latest schedule change as missed")
    func respectsScheduleUpdatedAt() async throws {
        let generator = GeneratorSpy(isAvailable: true)
        let recentlyChangedTracker = problemTracker(scheduleUpdatedAt: date("2025-09-01"))
        let history = HistoryProviderSpy(
            trackers: [recentlyChangedTracker, referenceTracker()],
            records: saturdayRecords()
        )
        let useCase = makeUseCase(history: history, generator: generator)

        let insight = try await useCase.execute()

        #expect(insight == nil)
        #expect(await generator.receivedCandidates.isEmpty)
    }

    @Test("does not suggest an alternative weekday without enough supporting evidence")
    func requiresReliableAlternative() async throws {
        let generator = GeneratorSpy(isAvailable: true)
        let history = HistoryProviderSpy(
            trackers: [problemTracker(), referenceTracker()],
            records: [
                record(referenceTrackerID, "2025-08-23"),
                record(referenceTrackerID, "2025-08-30")
            ]
        )
        let useCase = makeUseCase(history: history, generator: generator)

        let insight = try await useCase.execute()

        #expect(insight == nil)
        #expect(await generator.receivedCandidates.isEmpty)
    }

    @Test("ignores the current unfinished day")
    func ignoresCurrentDay() async throws {
        let mondayTracker = tracker(
            id: problemTrackerID,
            name: "Чтение",
            schedule: [.monday],
            createdAt: date("2025-08-18")
        )
        let tuesdayReference = tracker(
            id: referenceTrackerID,
            name: "Прогулка",
            schedule: [.tuesday],
            createdAt: date("2025-08-18")
        )
        let generator = GeneratorSpy(isAvailable: true)
        let history = HistoryProviderSpy(
            trackers: [mondayTracker, tuesdayReference],
            records: [
                record(problemTrackerID, "2025-08-18"),
                record(problemTrackerID, "2025-08-25"),
                record(problemTrackerID, "2025-09-01"),
                record(problemTrackerID, "2025-09-08"),
                record(referenceTrackerID, "2025-08-19"),
                record(referenceTrackerID, "2025-08-26"),
                record(referenceTrackerID, "2025-09-02"),
                record(referenceTrackerID, "2025-09-09")
            ]
        )
        let useCase = makeUseCase(history: history, generator: generator)

        let insight = try await useCase.execute()

        #expect(insight == nil)
        #expect(await generator.receivedCandidates.isEmpty)
    }
}

@Suite("ApplyStatisticsInsightUseCase")
struct ApplyStatisticsInsightUseCaseTests {
    @Test("moves the tracker schedule and its notification to the suggested day")
    func appliesSuggestedDay() async throws {
        let trackerID = UUID()
        let sectionID = UUID()
        let timestamp = Date(timeIntervalSince1970: 1_757_930_400)
        let notificationTime = Date(timeIntervalSince1970: 36_000)
        let tracker = Tracker(
            id: trackerID,
            name: "Тренировка",
            emoji: "🏋️",
            color: "#000000",
            schedule: [.friday],
            sectionId: sectionID,
            notificationInformation: TrackerNotificationInformation(
                trackerId: trackerID,
                isGlobalEnabled: true,
                schedule: [
                    .friday: .init(weekDay: .friday, isEnabled: true, time: notificationTime)
                ]
            )
        )
        let store = AppliedTrackerStore(tracker: tracker)
        let useCase = ApplyStatisticsInsightUseCase(
            fetchTracker: { id in await store.fetch(id: id) },
            updateTracker: { updated in await store.update(updated) },
            now: { timestamp }
        )
        let insight = StatisticsInsight(
            trackerID: trackerID,
            trackerName: tracker.name,
            title: "Перенести тренировку",
            explanation: "По пятницам привычка часто пропускается.",
            evidence: .init(observedWeekDay: .friday, completedCount: 0, scheduledCount: 4),
            proposedAction: .moveSchedule(from: .friday, to: .saturday)
        )

        try await useCase.execute(insight)

        let updated = try #require(await store.updatedTracker)
        #expect(updated.weekDays == [.saturday])
        #expect(updated.scheduleUpdatedAt == timestamp)
        #expect(updated.notificationInformation?.schedule[.friday] == nil)
        #expect(updated.notificationInformation?.schedule[.saturday]?.weekDay == .saturday)
        #expect(updated.notificationInformation?.schedule[.saturday]?.time == notificationTime)
    }
}

private actor AppliedTrackerStore {
    let tracker: Tracker
    private(set) var updatedTracker: Tracker?

    init(tracker: Tracker) {
        self.tracker = tracker
    }

    func fetch(id: UUID) -> Tracker? {
        tracker.id == id ? tracker : nil
    }

    func update(_ tracker: Tracker) {
        updatedTracker = tracker
    }
}

private extension GenerateStatisticsInsightUseCaseTests {
    func makeUseCase(
        history: HistoryProviderSpy,
        generator: GeneratorSpy
    ) -> GenerateStatisticsInsightUseCase {
        GenerateStatisticsInsightUseCase(
            historyProvider: history,
            generator: generator,
            calendar: calendar,
            now: { now }
        )
    }

    func problemTracker(scheduleUpdatedAt: Date? = nil) -> Tracker {
        tracker(
            id: problemTrackerID,
            name: "Тренировка",
            schedule: [.friday],
            createdAt: date("2025-08-18"),
            scheduleUpdatedAt: scheduleUpdatedAt
        )
    }

    func referenceTracker() -> Tracker {
        tracker(
            id: referenceTrackerID,
            name: "Прогулка",
            schedule: [.saturday],
            createdAt: date("2025-08-18")
        )
    }

    func tracker(
        id: UUID,
        name: String,
        schedule: Set<WeekDay>,
        createdAt: Date,
        scheduleUpdatedAt: Date? = nil
    ) -> Tracker {
        Tracker(
            id: id,
            name: name,
            emoji: "✅",
            color: "#000000",
            schedule: schedule,
            sectionId: UUID(),
            notificationInformation: nil,
            createdAt: createdAt,
            scheduleUpdatedAt: scheduleUpdatedAt
        )
    }

    func saturdayRecords() -> [TrackerRecord] {
        ["2025-08-23", "2025-08-30", "2025-09-06", "2025-09-13"]
            .map { record(referenceTrackerID, $0) }
    }

    func record(_ trackerID: UUID, _ day: String) -> TrackerRecord {
        TrackerRecord(id: trackerID, date: date(day))
    }

    func date(_ day: String) -> Date {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: day)!
    }
}

private actor HistoryProviderSpy: StatisticsInsightHistoryProviding {
    private let trackers: [Tracker]
    private let records: [TrackerRecord]
    private(set) var fetchCount = 0

    init(trackers: [Tracker], records: [TrackerRecord]) {
        self.trackers = trackers
        self.records = records
    }

    func fetchTrackers() -> [Tracker] {
        fetchCount += 1
        return trackers
    }

    func fetchRecords() -> [TrackerRecord] {
        fetchCount += 1
        return records
    }
}

private actor GeneratorSpy: StatisticsInsightGenerating {
    let isAvailable: Bool
    private let copy: StatisticsInsightCopy
    private(set) var receivedCandidates: [StatisticsInsightCandidate] = []

    init(
        isAvailable: Bool,
        copy: StatisticsInsightCopy = StatisticsInsightCopy(title: "Title", explanation: "Explanation")
    ) {
        self.isAvailable = isAvailable
        self.copy = copy
    }

    func generateCopy(for candidate: StatisticsInsightCandidate) -> StatisticsInsightCopy {
        receivedCandidates.append(candidate)
        return copy
    }
}
