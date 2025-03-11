import Foundation

public protocol TrackerManaging: Sendable {
    associatedtype StateSequence: AsyncSequence where StateSequence.Element == [Tracker]
    associatedtype StateSectionSequence: AsyncSequence where StateSectionSequence.Element == [TrackerSection]
    
    var pinnedTrackers: StateSequence { get }
    var sections: StateSectionSequence { get }
    
    func getAllRegularTrackers() async throws
    func getAllPinnedTrackers() async throws
    func addCategory(withId id: UUID, toTracker tracker: Tracker) async throws
    func togglePin(for tracker: Tracker) async throws    
    func delete(tracker: Tracker) async throws
    func daysTracked(for tracker: Tracker) -> Int
    func isCompleted(tracker: Tracker, for date: Date) -> Bool
    func saveAsCompleted(tracker: Tracker, for date: Date)
}

final class TrackerManager: TrackerManaging {
    private let trackerRepository: TrackerRepositoryProtocol
    private let recordRepository: RecordRepositoryProtocol
    private let category: CategoryRepositoryProtocol
    
    private let mutablePinnedTrackers = ObservableActor<[Tracker]>([])
    let pinnedTrackers: ReadOnlyObservableWrapper<[Tracker]>
    
    private let mutableSections = ObservableActor<[TrackerSection]>([])
    let sections: ReadOnlyObservableWrapper<[TrackerSection]>
    
    init(
        trackerRepository: TrackerRepositoryProtocol,
        recordRepository: RecordRepositoryProtocol,
        category: CategoryRepositoryProtocol
    ) {
        self.trackerRepository = trackerRepository
        self.recordRepository = recordRepository
        self.category = category
        
        pinnedTrackers = mutablePinnedTrackers.readOnly()
        sections = mutableSections.readOnly()
        
//        trackerRepository.addPrepared(sections: mockTrackerSections)
    }
    
    // MARK: - Public methods
    
    func getAllPinnedTrackers() async throws {
        let pinnedTrackers = try await trackerRepository.getAllTrackers(isPinned: true)
        
        await mutablePinnedTrackers.setIfNeeded(value: pinnedTrackers)
    }
    
    func getAllRegularTrackers() async throws {
        let regularTrackers = try await trackerRepository.getAllTrackers(isPinned: false)
        
        var categoriesDict: [UUID: TrackerSection] = [:]
        
        for tracker in regularTrackers where categoriesDict[tracker.categoryId] == nil {
            let category = try await category.getCategory(by: tracker.categoryId)
            categoriesDict[tracker.categoryId] = category
        }
        
        for tracker in regularTrackers {
            if let section = categoriesDict[tracker.categoryId] {
                var updatedTrackers = section.trackers
                updatedTrackers.append(tracker)
                                
                let updatedSection = TrackerSection(
                    id: section.id,
                    title: section.title,
                    trackers: updatedTrackers
                )
                categoriesDict[tracker.categoryId] = updatedSection
            }
        }
        
        await mutableSections.setIfNeeded(value: Array(categoriesDict.values))
    }
    
    func delete(tracker: Tracker) async throws {
        try await trackerRepository.deleteTracker(with: tracker.id)
        
        if tracker.isPinned {
            try await getAllPinnedTrackers()
        }
        else {
            try await getAllRegularTrackers()
        }
    }
    
    func togglePin(for tracker: Tracker) async throws {
        try await trackerRepository.updateTracker(tracker.toggleIsPinned())
        try await updateAll()
    }
    
    func updateAll() async throws {
        try await getAllPinnedTrackers()
        try await getAllRegularTrackers()
    }
    
    func daysTracked(for tracker: Tracker) -> Int {
        recordRepository.getTrackedDaysFor(id: tracker.id)
    }
    
    func isCompleted(tracker: Tracker, for date: Date) -> Bool {
//        recordRepository.isCompletedFor(selectedDay: date, trackerWithId: tracker.id)
        false
    }
    
    func saveAsCompleted(tracker: Tracker, for date: Date) {
        recordRepository.removeOrAddRecordOf(tracker: tracker, forParticularDay: date)
    }
    
    func addCategory(withId id: UUID, toTracker tracker: Tracker) async throws {
//        try await trackerRepository.addCategory(withId: id, toTracker: tracker)
    }
}
