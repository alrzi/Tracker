import CoreData

protocol TrackerRecordStoreProtocol {
    func getTrackedDaysNumberFor(trackerWithId id: UUID?) throws -> Int
    func isCompletedFor(_ selectedDay: String, trackerWithId id: UUID?) -> Bool
    func removeOrAddRecordOf(tracker: TrackerObject, forParticularDay day: String) throws
    func getNumberOfCompletedTrackers() -> Int
    func getAllRecords() -> [RecordObject]?
}

struct TrackerRecordStore: Store {
    typealias EntityType = RecordObject
        
    let context: NSManagedObjectContext
    var predicateBuilder: TrackerRecordPredicateBuilderProtocol
    
    init(
        context: NSManagedObjectContext,
        predicateBuilder: TrackerRecordPredicateBuilderProtocol = PredicateBuilder()
    ) {
        self.context = context
        self.predicateBuilder = predicateBuilder
    }

    init() {
        let context = ManagedObjectContext.shared.context
        self.init(context: context)
    }
}

// MARK: - Public
extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func getTrackedDaysNumberFor(trackerWithId id: UUID?) throws -> Int {
        guard let id = id else { return .zero }
        return getObjectBy(id: UUID())?.count ?? .zero
    }

    func getNumberOfCompletedTrackers() -> Int {
        let fetchRequest = RecordObject.fetchRequest()
        let trackerRecordsCoreData = try? context.fetch(fetchRequest)
        return trackerRecordsCoreData?.count ?? .zero
    }
    
    func isCompletedFor(_ selectedDay: String, trackerWithId id: UUID?) -> Bool {
        guard let id = id else { return false }
        let fetchRequest = RecordObject.fetchRequest()
        let predicate = predicateBuilder.buildPredicateIsCompletedFor(selectedDate: selectedDay, trackerWithId: id)
        fetchRequest.predicate = predicate
        
        do {
            let trackerRecordsCoreData = try context.fetch(fetchRequest)
            return trackerRecordsCoreData.first != nil ? true : false
        }
        catch {
            return false
        }
    }
    
    func removeOrAddRecordOf(tracker: TrackerObject, forParticularDay day: String) throws {
        let recordRequest = NSFetchRequest<RecordObject>(entityName: RecordObject.entityName)
        let trackerRecordCoreData = try context.fetch(recordRequest)
        
        if let trackerToRemoveIndex = trackerRecordCoreData.firstIndex(
            where: { $0.date == .now && $0.id == tracker.id }) {
            // Remove the tracker record from the array
            context.delete(trackerRecordCoreData[trackerToRemoveIndex])
        } else {
            // Create new record
            let trackerRecord = RecordObject(context: context)
            trackerRecord.id = tracker.id
            trackerRecord.date = .now
            trackerRecord.tracker = tracker
        }
        
        save()
    }

    func getAllRecords() -> [RecordObject]? {
        let recordRequest = NSFetchRequest<RecordObject>(entityName: RecordObject.entityName)
        return try? context.fetch(recordRequest)
    }
}
