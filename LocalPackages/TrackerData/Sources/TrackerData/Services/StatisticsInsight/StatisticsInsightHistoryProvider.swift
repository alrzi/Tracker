import TrackerDomain

struct StatisticsInsightHistoryProvider: StatisticsInsightHistoryProviding {
    private let trackerRepository: any TrackerRepositoryProtocol
    private let recordRepository: any RecordRepositoryProtocol

    init(
        trackerRepository: some TrackerRepositoryProtocol,
        recordRepository: some RecordRepositoryProtocol
    ) {
        self.trackerRepository = trackerRepository
        self.recordRepository = recordRepository
    }

    func fetchTrackers() async throws -> [Tracker] {
        try await trackerRepository.getTrackers()
    }

    func fetchRecords() async throws -> [TrackerRecord] {
        try await recordRepository.fetchRecords()
    }
}
