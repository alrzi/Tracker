import Foundation

protocol TrackerManagerProtocol {
    func getCategoryNameFor(trackerID: UUID) -> String?
    func getTrackerBy(id: UUID) -> TrackerObject?
    func getHeaderName() -> String?
    func getTrackedDaysNumberFor(id: UUID) -> Int?
    func isCompletedFor(date: String, trackerWithId id: UUID) -> Bool?
    func markAsTrackedFor(date: String?, trackerWithId id: UUID?) throws
    func createTracker(kind: TrackerKind, name: String?, emoji: String?, color: String?, schedule: Set<Int>?, categoryHeader: String?) throws
    func updateTracker(kind: TrackerKind, id: UUID, name: String?, emoji: String?, color: String?, schedule: Set<Int>?, categoryHeader: String?, isAttached: Bool) throws
}

struct TrackerManagerImpl: TrackerManagerProtocol {
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private let trackerStore: TrackerStoreManagerProtocol
    private let trackerRecordStore: TrackerRecordStoreProtocol
    
    init(
        trackerCategoryStore: TrackerCategoryStoreProtocol,
        trackerStore: TrackerStoreManagerProtocol,
        trackerRecordStore: TrackerRecordStoreProtocol
    ) {
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerStore = trackerStore
        self.trackerRecordStore = trackerRecordStore
    }
    
    // MARK: - Public methods
    
    func createTracker(
        kind: TrackerKind,
        name: String?,
        emoji: String?,
        color: String?,
        schedule: Set<Int>?,
        categoryHeader: String?
    ) throws {
        guard let name = name,
            let emoji = emoji,
            let color = color,
            let schedule = schedule,
            let categoryHeader = categoryHeader else { return }
        
        var tracker: Tracker
        switch kind {
        case .habit:
            tracker = Tracker(
                id: UUID(),
                name: name,
                emoji: emoji,
                color: color,
                schedule: schedule,
                kind: kind
            )
        case .occasional:
            tracker = Tracker(
                id: UUID(),
                name: name,
                emoji: emoji,
                color: color,
                schedule: WeekDay.allDaysOfWeek,
                kind: kind
            )
        }
        
        let trackerCoreData = try trackerStore.createTrackerCoreData(tracker)
        try trackerCategoryStore.addTracker(toCategoryWithName: categoryHeader, tracker: trackerCoreData)
    }
    
    func updateTracker(kind: TrackerKind, id: UUID, name: String?, emoji: String?, color: String?, schedule: Set<Int>?, categoryHeader: String?, isAttached: Bool) throws {
        guard
            let name = name,
            let emoji = emoji,
            let color = color,
            let schedule = schedule,
            let categoryHeader = categoryHeader else { return }
        
        let tracker = Tracker(
            id: id,
            name: name,
            emoji: emoji,
            color: color,
            schedule: schedule,
            isAttached: isAttached,
            kind: kind
        )
        
        if let category = try trackerCategoryStore.addCategory(with: categoryHeader) {
            try trackerStore.save(tracker: tracker, andUpdateItsCategory: category)
        }
    }
    
    func getCategoryNameFor(trackerID: UUID) -> String? {
        trackerStore.getCategoryHeaderForTrackerWith(id: trackerID)
    }
    
    func getTrackedDaysNumberFor(id: UUID) -> Int? {
        trackerStore.getTrackedDaysNumberFor(id: id)
    }
    
    func isCompletedFor(date: String, trackerWithId id: UUID) -> Bool? {
        try? trackerRecordStore.isCompletedFor(date, trackerWithId: id)
    }
    
    func getTrackerBy(id: UUID) -> TrackerObject? {
        trackerStore.getObjectBy(id: .init())?.first
    }
    
    func getHeaderName() -> String? {
        trackerCategoryStore.getNameOfLastSelectedCategory()
    }
    
    func markAsTrackedFor(date: String?, trackerWithId id: UUID?) throws {
        if let id, let date, let tracker = trackerStore.getObjectBy(id: .init())?.first {
            try trackerRecordStore.removeOrAddRecordOf(tracker: tracker, forParticularDay: date)
        }
    }
}
