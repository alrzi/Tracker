import Foundation

protocol TrackerManaging {
    func addCategory(withId id: UUID, toTracker tracker: Tracker) throws
    func getTrackerBy(id: UUID) throws -> Tracker
}

final class TrackerManager: TrackerManaging {
    private let trackerRepository: TrackerRepository
    
    init(trackerRepository: TrackerRepository) {
        self.trackerRepository = trackerRepository
    }
    
    // MARK: - Public methods
    
    func addCategory(withId id: UUID, toTracker tracker: Tracker) throws {
        try trackerRepository.addCategory(withId: id, toTracker: tracker)
    }
    
    func getTrackerBy(id: UUID) throws -> Tracker {
        try trackerRepository.getTracker(by: id)
    }
}
