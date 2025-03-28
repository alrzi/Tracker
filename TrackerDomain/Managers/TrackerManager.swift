import Foundation

public protocol TrackerManaging: Sendable {
    associatedtype StateSectionSequence: AsyncSequence where StateSectionSequence.Element == [TrackerSection]
    
    var sections: StateSectionSequence { get }
    
    // Create
    func addSection(withId id: UUID, toTracker tracker: Tracker) async throws
    func addSections(_ sections: [TrackerSection]) async throws
    
    // Read
    func fetchCompletedSections(params: RequestParameters, isPaginating: Bool) async throws -> ([TrackerSection], [Tracker])
    func fetchUnCompletedSections(params: RequestParameters, isPaginating: Bool) async throws -> ([TrackerSection], [Tracker])
    func fetchSections(params: RequestParameters, isPaginating: Bool) async throws -> ([TrackerSection], [Tracker])
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
    
    func fetchSections(params: RequestParameters, isPaginating: Bool) async throws -> ([TrackerSection], [Tracker]) {
        let sections = try await categoryRepository.getSections(params: params)
        
        var tempPinned: [Tracker] = []
        
        if !isPaginating {
            async let pinned = trackerRepository.getTrackers(isPinned: true, weekDay: params.weekDay, query: params.query)
            
            var updatedTrackers: [Tracker] = []
            
            for tracker in try await pinned {
                let isCompleted = try await recordRepository.isCompletedFor(selectedDay: params.currentDate, trackerWithId: tracker.id)
                updatedTrackers.append(tracker.with(isCompleted: isCompleted))
            }
            
            tempPinned = updatedTrackers
        }
        
        async let regular = fetchTrackers(for: sections, params: params).sorted { $0.title < $1.title }
        
        return (try await regular, tempPinned)
    }
    
    func fetchCompletedSections(params: RequestParameters, isPaginating: Bool) async throws -> ([TrackerSection], [Tracker]) {
        let sections = try await categoryRepository.getSections(params: params, isCompleted: true)
        
        var tempPinned: [Tracker] = []
        
        if !isPaginating {
            async let pinnedRecords = recordRepository.fetchRecords(for: params.currentDate, weekDay: params.weekDay, query: params.query, isPinned: true)
            
            for pinnedRecord in try await pinnedRecords {
                let trackers = try await trackerRepository.getTrackers(id: pinnedRecord.id)
                tempPinned.append(contentsOf: trackers.map { $0.with(isCompleted: true) })
            }
        }
        
        async let regular = fetchCompletedTrackers(for: sections, params: params).sorted { $0.title < $1.title }
        
        return (try await regular, tempPinned)
    }
    
    func fetchUnCompletedSections(params: RequestParameters, isPaginating: Bool) async throws -> ([TrackerSection], [Tracker]) {
        let sections = try await categoryRepository.getSections(params: params, isCompleted: false)
        
        var tempPinned: [Tracker] = []
        
        if !isPaginating {
            async let pinnedRecords = trackerRepository.getTrackers(isPinned: true, weekDay: params.weekDay, query: params.query, date: params.currentDate)
            tempPinned = try await pinnedRecords
        }
        
        async let regular = fetchUnCompletedTrackers(for: sections, params: params).sorted { $0.title < $1.title }
        
        return (try await regular, tempPinned)
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
    func fetchTrackers(for sections: [TrackerSection], params: RequestParameters) async throws -> [TrackerSection] {
        try await fetchTrackers(
            for: sections,
            fetchTask: { [trackerRepository] section in
                try await trackerRepository.getTrackers(for: section.id, isPinned: false, weekDay: params.weekDay, query: params.query)
            },
            mapToTrackerSection: { [recordRepository] section, trackers in
                var updatedTrackers: [Tracker] = []
                
                for tracker in trackers {
                    let isCompleted = try await recordRepository.isCompletedFor(selectedDay: params.currentDate, trackerWithId: tracker.id)
                    updatedTrackers.append(tracker.with(isCompleted: isCompleted))
                }
                
                return TrackerSection(id: section.id, title: section.title, trackers: updatedTrackers)
            }
        )
    }
    
    func fetchCompletedTrackers(for sections: [TrackerSection], params: RequestParameters) async throws -> [TrackerSection] {
        try await fetchTrackers(
            for: sections,
            fetchTask: { [recordRepository] section in
                try await recordRepository.fetchRecords(
                    for: section.id,
                    for: params.currentDate,
                    weekDay: params.weekDay,
                    query: params.query,
                    isPinned: false
                )
            },
            mapToTrackerSection: { [trackerRepository] section, records in
                var updatedTrackers: [Tracker] = []
                
                for record in records {
                    let trackers = try await trackerRepository.getTrackers(id: record.id)
                    updatedTrackers.append(contentsOf: trackers.map { $0.with(isCompleted: true) })
                }
                
                return TrackerSection(id: section.id, title: section.title, trackers: updatedTrackers)
            }
        )
    }
    
    func fetchUnCompletedTrackers(for sections: [TrackerSection], params: RequestParameters) async throws -> [TrackerSection] {
        try await fetchTrackers(
            for: sections,
            fetchTask: { [trackerRepository] section in
                try await trackerRepository.getTrackers(for: section.id, isPinned: false, weekDay: params.weekDay, query: params.query, date: params.currentDate)
            },
            mapToTrackerSection: { section, trackers in
                TrackerSection(id: section.id, title: section.title, trackers: trackers)
            }
        )
    }
    
    func fetchTrackers<T>(
        for sections: [TrackerSection],
        fetchTask: @escaping (TrackerSection) async throws -> [T],
        mapToTrackerSection: @escaping (TrackerSection, [T]) async throws -> TrackerSection?
    ) async throws -> [TrackerSection] {
        try await withThrowingTaskGroup(of: TrackerSection?.self, returning: [TrackerSection].self) { group in
            for section in sections {
                group.addTask {
                    let items = try await fetchTask(section)
                    
                    guard !items.isEmpty else {
                        return nil
                    }
                    
                    return try await mapToTrackerSection(section, items)
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
