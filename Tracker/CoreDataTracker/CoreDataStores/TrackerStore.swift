import CoreData

protocol TrackerStoreManagerProtocol {
    func createTrackerCoreData(_ tracker: Tracker) throws -> TrackerObject
    func save(tracker: Tracker, andUpdateItsCategory category: CategoryObject) throws
    func getCategoryHeaderForTrackerWith(id: UUID) -> String?
    func getTrackedDaysNumberFor(id: UUID) -> Int?
    func getObjectBy(id: UUID) -> [TrackerObject]?
    func delete(_ entity: TrackerObject) throws
    func object<T: NSManagedObject>(_ type: T.Type, with moID: NSManagedObjectID) -> T?
}

protocol TrackerStoreDataProviderProtocol {
    func createTrackerCoreData(_ tracker: Tracker) throws -> TrackerObject
    func delete(_ record: TrackerObject) throws
    var isAnyTrackers: Bool { get }
}

struct TrackerStore: Store {
    typealias EntityType = TrackerObject
    
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    init() {
        let context = ManagedObjectContext.shared.context
        self.init(context: context)
    }
}

// MARK: - TrackerStoreManagerProtocol
extension TrackerStore: TrackerStoreManagerProtocol {
    func getCategoryHeaderForTrackerWith(id: UUID) -> String? {
//        let trackerCoreData = getObjectBy(id: UUID())?.first
//        return trackerCoreData?.lastCategory ?? trackerCoreData?.category?.title
        nil
    }
    
    func getTrackedDaysNumberFor(id: UUID) -> Int? {
        getObjectBy(id: id)?.first?.trackerRecord?.count
    }
    
    func save(tracker: Tracker, andUpdateItsCategory category: CategoryObject) throws {
        if let trackerCoreData = getObjectBy(id: tracker.id)?.first {
            trackerCoreData.update(with: tracker)
            save()
        }
    }
    
    func object<T: NSManagedObject>(_ type: T.Type, with moID: NSManagedObjectID) -> T? {
        do {
            let object = try context.existingObject(with: moID)
            return object as? T
        } catch let err {
            return nil
        }
    }
}

// MARK: - TrackerStoreDataProviderProtocol
extension TrackerStore: TrackerStoreDataProviderProtocol {
    func createTrackerCoreData(_ tracker: Tracker) -> TrackerObject {
        return TrackerObject(from: tracker, context: context)
    }

    var isAnyTrackers: Bool {
        let fetchRequest = TrackerObject.fetchRequest()
        let trackers = try? context.fetch(fetchRequest)
        if let trackers {
            return trackers.isEmpty ? false : true
        }
        return false
    }
}

extension TrackerObject {
    convenience init(from tracker: Tracker, context: NSManagedObjectContext) {
        self.init(context: context)
        update(with: tracker)
    }
    
    func update(with tracker: Tracker) {
        self.id = tracker.id
        self.name = tracker.name
        self.emoji = tracker.emoji
        self.color = tracker.color
        self.weekDays = tracker.schedule.toNumbersString()
        self.isPinned = tracker.isAttached
        self.kind = tracker.kind
    }
}
