import Foundation
import CoreData.NSManagedObjectID

protocol TrackerManaging {
    var trackers: [Tracker] { get }
    
    func addCategory(withId id: UUID, toTracker tracker: Tracker) throws
    func getTrackerBy(id: UUID) throws -> Tracker
    func getTrackerBy(id: NSManagedObjectID) -> Tracker?
    func pin(tracker: Tracker) throws
    func unPin(tracker: Tracker) throws
    func deleteTrackerBy(id: UUID) throws
    func daysTracked(for tracker: Tracker) -> Int
    func isCompleted(tracker: Tracker, for date: Date) -> Bool
    func saveAsCompleted(tracker: Tracker, for date: Date)
}

final class TrackerManager: TrackerManaging {
    private let trackerRepository: TrackerRepository
    private let recordRepository: RecordRepository
    
    var trackers: [Tracker] {
        trackerRepository.getAllTrackers()
    }
    
    init(
        trackerRepository: TrackerRepository,
        recordRepository: RecordRepository
    ) {
        self.trackerRepository = trackerRepository
        self.recordRepository = recordRepository
    }
    
    // MARK: - Public methods
    
    func addCategory(withId id: UUID, toTracker tracker: Tracker) throws {
        try trackerRepository.addCategory(withId: id, toTracker: tracker)
    }
    
    func getTrackerBy(id: UUID) throws -> Tracker {
        let tracker = try trackerRepository.getTracker(by: id)
        let trackedDays = recordRepository.getTrackedDaysFor(id: id)
        
        return tracker
            .updated(trackedDays: trackedDays)
    }
    
    func getTrackerBy(id: NSManagedObjectID) -> Tracker? {
        guard let tracker = trackerRepository.getTracker(by: id) else {
            return nil
        }
        
        let trackedDays = recordRepository.getTrackedDaysFor(id: tracker.id)
        
        return tracker
            .updated(trackedDays: trackedDays)
    }
    
    func deleteTrackerBy(id: UUID) throws {
        try trackerRepository.deleteTracker(with: id)
    }
    
    func pin(tracker: Tracker) throws {
        let updatedTracker = tracker.toggleIsPinned()
        try trackerRepository.updateTracker(updatedTracker)
    }
    
    func unPin(tracker: Tracker) throws {
        let updatedTracker = tracker.toggleIsPinned()
        try trackerRepository.updateTracker(updatedTracker)
    }
    
    func daysTracked(for tracker: Tracker) -> Int {
        recordRepository.getTrackedDaysFor(id: tracker.id)
    }
    
    func isCompleted(tracker: Tracker, for date: Date) -> Bool {
        recordRepository.isCompletedFor(selectedDay: date, trackerWithId: tracker.id)
    }
    
    func saveAsCompleted(tracker: Tracker, for date: Date) {
        recordRepository.removeOrAddRecordOf(tracker: tracker, forParticularDay: date)
    }
}
