import Foundation

public protocol TrackerManaging: Sendable {
    associatedtype StateSectionSequence: AsyncSequence where StateSectionSequence.Element == [TrackerSection]
    
    var sections: StateSectionSequence { get }
        
    func addSection(withId id: UUID, toTracker tracker: Tracker) async throws
    func addSections(_ sections: [TrackerSection]) async throws
    func togglePin(for tracker: Tracker) async throws
    func delete(tracker: Tracker) async throws    
    func isCompleted(tracker: Tracker, for date: Date) async throws -> Bool
    func toggle(record: TrackerRecord) async throws
    func daysTracked(for tracker: Tracker) async throws -> Int
    func fetchAllSectionedTrackers() async throws
}

final class TrackerManager: TrackerManaging {
    private let trackerRepository: TrackerRepositoryProtocol
    private let recordRepository: RecordRepositoryProtocol
    private let categoryRepository: CategoryRepositoryProtocol
    
    private let mutableSections = ObservableActor<[TrackerSection]>([])
    let sections: ReadOnlyObservableWrapper<[TrackerSection]>
    
    init(
        trackerRepository: TrackerRepositoryProtocol,
        recordRepository: RecordRepositoryProtocol,
        categoryRepository: CategoryRepositoryProtocol
    ) {
        self.trackerRepository = trackerRepository
        self.recordRepository = recordRepository
        self.categoryRepository = categoryRepository
               
        sections = mutableSections.readOnly()
    }
    
    // MARK: - Create
    
    func addSection(withId id: UUID, toTracker tracker: Tracker) async throws {
        try await trackerRepository.addSection(withId: id, toTracker: tracker)
        try await fetchAllSectionedTrackers()
    }
    
    func addSections(_ sections: [TrackerSection]) async throws {
        try await categoryRepository.createSections(sections)
    }
    
    // MARK: - Read
    
    func fetchAllSectionedTrackers() async throws {
        let weekDay: String = "0, 1, 2, 3, 4, 5, 6"
        
        let sections = try await categoryRepository.getAllSections(weekDay: weekDay)
        
        async let pinned = trackerRepository.getAllTrackers(isPinned: true)
        
        async let regular = withThrowingTaskGroup(of: TrackerSection?.self, returning: [TrackerSection].self) { [trackerRepository] group in
            for section in sections {
                group.addTask {
                    let trackers = try await trackerRepository.getAllTrackersForCategory(category: section.id, isPinned: false, weekDay: weekDay)
                    
                    if trackers.isEmpty {
                        return nil
                    }
                    else {
                        return TrackerSection(
                            id: section.id,
                            title: section.title,
                            trackers: trackers
                        )
                    }
                }
            }
            
            return try await group.reduce(into: []) { accumulatedSections, section in
                if let validSection = section {
                    accumulatedSections.append(validSection)
                }
            }
        }
        
        let tempPinned = try await pinned
        var tempSections = try await regular
        
        if !tempPinned.isEmpty {
            tempSections.insert(.init(title: "Pinned", trackers: tempPinned), at: 0)
        }
        
        await mutableSections.setIfNeeded(value: tempSections)
    }
    
    func daysTracked(for tracker: Tracker) async throws -> Int {
        try await recordRepository.getTrackedDaysFor(id: tracker.id)
    }
    
    func isCompleted(tracker: Tracker, for date: Date) async throws -> Bool {
        try await recordRepository.isCompletedFor(selectedDay: date, trackerWithId: tracker.id)
    }
    
    // MARK: - Update
    
    func togglePin(for tracker: Tracker) async throws {
        try await trackerRepository.updateTracker(tracker.toggleIsPinned())
        try await fetchAllSectionedTrackers()
    }
    
    func toggle(record: TrackerRecord) async throws {
        try await recordRepository.createOrDeleteIfPresent(record: record, for: record.id)
        try await fetchAllSectionedTrackers()
    }
    
    // MARK: - Delete
    
    func delete(tracker: Tracker) async throws {
        try await trackerRepository.deleteTracker(with: tracker.id)
        try await fetchAllSectionedTrackers()
    }
}
