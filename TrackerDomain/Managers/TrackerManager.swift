import Foundation

public protocol TrackerManaging: Sendable {
    associatedtype StateSectionSequence: AsyncSequence where StateSectionSequence.Element == [TrackerSection]
    
    var sections: StateSectionSequence { get }
        
    // Create
    func addSection(withId id: UUID, toTracker tracker: Tracker) async throws
    func addSections(_ sections: [TrackerSection]) async throws
    
    // Read
    func fetchSections(
        with query: String,
        for weekDay: String,
        fetchLimit: Int,
        fetchOffset: Int,
        currentDate: Date
    ) async throws -> ([TrackerSection], [Tracker])
    
    func fetchSectionsNextPage(for query: String, for weekDay: String, fetchLimit: Int, fetchOffset: Int, currentDate: Date) async throws -> [TrackerSection]
    func fetchSection(by id: UUID) async throws -> TrackerSection
    func daysTracked(for tracker: Tracker) async throws -> Int
    func isCompleted(tracker: Tracker, for date: Date) async throws -> Bool
    
    // Update
    func update(tracker: Tracker) async throws
    func toggle(record: TrackerRecord) async throws
    
    // Delete
    func delete(tracker: Tracker) async throws
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
    }
    
    func addSections(_ sections: [TrackerSection]) async throws {
        try await categoryRepository.createSections(sections)
    }
    
    // MARK: - Read
    
    func fetchSectionsNextPage(for query: String, for weekDay: String, fetchLimit: Int, fetchOffset: Int, currentDate: Date) async throws -> [TrackerSection] {
        let sections = try await categoryRepository.getSections(
            with: query,
            for: weekDay,
            fetchLimit: fetchLimit,
            fetchOffset: fetchOffset
        )
        
        let regular = try await fetchTrackers(for: sections, weekDay: weekDay, query: query, currentDate: currentDate).sorted { $0.title < $1.title }
        
        return regular
    }
    
    func fetchSections(
        with query: String,
        for weekDay: String,
        fetchLimit: Int,
        fetchOffset: Int,
        currentDate: Date
    ) async throws -> ([TrackerSection], [Tracker]) {
        let sections = try await categoryRepository.getSections(
            with: query,
            for: weekDay,
            fetchLimit: fetchLimit,
            fetchOffset: fetchOffset
        )
        
        async let pinned = trackerRepository.getAllTrackers(isPinned: true)
        async let regular = fetchTrackers(for: sections, weekDay: weekDay, query: query, currentDate: currentDate)
        
        let tempPinned = try await pinned
        let tempSections = try await regular.sorted { $0.title < $1.title }
                       
        return (tempSections, tempPinned)
    }
    
    func fetchSection(by id: UUID) async throws -> TrackerSection {
        try await categoryRepository.getCategory(by: id)
    }
    
    func daysTracked(for tracker: Tracker) async throws -> Int {
        try await recordRepository.getTrackedDaysFor(id: tracker.id)
    }
    
    func isCompleted(tracker: Tracker, for date: Date) async throws -> Bool {
        try await recordRepository.isCompletedFor(selectedDay: date, trackerWithId: tracker.id)
    }
    
    // MARK: - Update
    
    func update(tracker: Tracker) async throws {
        try await trackerRepository.updateTracker(tracker)
    }
    
    func toggle(record: TrackerRecord) async throws {
        try await recordRepository.createOrDeleteIfPresent(record: record)
    }
    
    // MARK: - Delete
    
    func delete(tracker: Tracker) async throws {
        try await trackerRepository.deleteTracker(with: tracker.id)        
    }
}

private extension TrackerManager {
    func fetchTrackers(for sections: [TrackerSection], weekDay: String, query: String, currentDate: Date) async throws -> [TrackerSection] {
        try await withThrowingTaskGroup(of: TrackerSection?.self, returning: [TrackerSection].self) { [trackerRepository, recordRepository] group in
            for section in sections {
                group.addTask {
                    let trackers = try await trackerRepository.getTrackers(for: section.id, isPinned: false, weekDay: weekDay, query: query)
                    
                    if trackers.isEmpty {
                        return nil
                    }
                    else {
                        var updatedTrackers: [Tracker] = []
                        
                        for tracker in trackers {
                            let isCompleted = try await recordRepository.isCompletedFor(selectedDay: currentDate, trackerWithId: tracker.id)
                            
                            updatedTrackers.append(tracker.with(isCompleted: isCompleted))
                        }
                                                
                        return TrackerSection(
                            id: section.id,
                            title: section.title,
                            trackers: updatedTrackers
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
    }
}
