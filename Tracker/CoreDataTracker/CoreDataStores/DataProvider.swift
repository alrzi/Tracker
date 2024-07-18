import Foundation
import CoreData

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: DataProviderUpdate)
    func noResultFound()
    func resultFound()
    func place()
}

protocol DataProviderProtocol {
    var delegate: DataProviderDelegate? { get set }
    var isEmpty: Bool { get }

    // DataSource
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func getTracker(at indexPath: IndexPath) -> Tracker?
    func header(for section: Int) -> String

    // Editing, Modifying
    func daysTracked(for indexPath: IndexPath) -> Int
    func saveAsCompletedTracker(with indexPath: IndexPath, for day: String) throws
    func isTrackerAt(indexPath: IndexPath, completedForDate date: String) -> Bool
    func deleteTracker(at indexPath: IndexPath) throws
    func pinTrackerAt(indexPath: IndexPath)
    func unPinTrackerAt(indexPath: IndexPath)

    // Filtering
    func fetchTrackersFor(weekDay: String) throws
    func fetchCompletedTrackersFor(date: String) throws
    func fetchTrackersWith(name: String, forWeekDay weekDay: String) throws
    func fetchCompletedTrackersWith(name: String, forDate date: String) throws
    func fetchUncompletedTrackersFor(weekDay: String, andForDate date: String) throws
    func fetchUncompletedTrackersWith(name: String, forWeekDay weekDay: String, andForDate date: String) throws
}

final class DataProvider: NSObject {
    // Idexes for delegate
    private var insertedSection: IndexSet?
    private var deletedSection: IndexSet?
    private var insertedIndexes: IndexPath?
    private var deletedIndexes: IndexPath?
    private var updatedIndexes: IndexPath?
    private var movedIndexes: Set<DataProviderUpdate.Move>?
    
    // Context -> one for 3 stores
    private let context: NSManagedObjectContext
    // Stores
    private let trackerStore: TrackerStoreManagerProtocol
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private let trackerRecordStore: TrackerRecordStoreProtocol
    // PredicateBuilder
    private var predicateBuilder: TrackerPredicateBuilderProtocol = PredicateBuilder()
    // Delegate
    weak var delegate: DataProviderDelegate?
    
    // Fetch controller
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerObject> = {
        let fetchRequest = NSFetchRequest<TrackerObject>(entityName: TrackerObject.entityName)
        fetchRequest.fetchBatchSize = 20
        fetchRequest.fetchLimit = 50
        let weekDay = Date().weekDayString
        fetchRequest.predicate = predicateBuilder.buildPredicateTrackersFor(weekDay: weekDay)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerObject.isPinned), ascending: false),
            NSSortDescriptor(key: #keyPath(TrackerObject.category.title), ascending: true),
            NSSortDescriptor(key: #keyPath(TrackerObject.name), ascending: true)
        ]

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerObject.category.title),
            cacheName: nil
        )
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch trackers: \(error)")
        }
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    // MARK: - Init
    init(context: NSManagedObjectContext) {
        self.context = context
        self.trackerStore = TrackerStore(context: context)
        self.trackerRecordStore = TrackerRecordStore(context: context)
        self.trackerCategoryStore = TrackerCategoryStore(context: context)
    }
}

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {
    var isEmpty: Bool {
        guard let objects = fetchedResultsController.fetchedObjects else { return false }
        return objects.isEmpty ? true : false
    }
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? .zero
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? .zero
    }

    func getTracker(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return Tracker(coreData: trackerCoreData)
    }
    
    func header(for section: Int) -> String {
        fetchedResultsController.sections?[section].name ?? ""
    }
    
    func daysTracked(for indexPath: IndexPath) -> Int {
        let tracker = fetchedResultsController.object(at: indexPath)
        do {
            return try trackerRecordStore.getTrackedDaysNumberFor(trackerWithId: tracker.id)
        } catch {
            return .zero
        }
    }
    
    func isTrackerAt(indexPath: IndexPath, completedForDate date: String) -> Bool {
        let tracker = fetchedResultsController.object(at: indexPath)
        do {
            return try trackerRecordStore.isCompletedFor(date, trackerWithId: tracker.id)
        } catch {
            return false
        }
    }

    func deleteTracker(at indexPath: IndexPath) throws {
        let tracker = fetchedResultsController.object(at: indexPath)
        try trackerStore.delete(tracker)
    }
    
    func saveAsCompletedTracker(with indexPath: IndexPath, for day: String) throws {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        try? trackerRecordStore.removeOrAddRecordOf(tracker: trackerCoreData, forParticularDay: day)
    }

    func pinTrackerAt(indexPath: IndexPath) {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
    }
    
    func unPinTrackerAt(indexPath: IndexPath) {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
    }
    
    // MARK: - Filtering
    func fetchTrackersFor(weekDay: String) throws {
        let predicate = predicateBuilder.buildPredicateTrackersFor(weekDay: weekDay)
        fetchedResultsController.fetchRequest.predicate = predicate
        try fetchedResultsController.performFetch()
        isEmpty ? delegate?.place() : delegate?.resultFound()
    }

    func fetchCompletedTrackersFor(date: String) throws {
        let predicate = predicateBuilder.buildPredicateCompletedTrackersFor(date: date)
        fetchedResultsController.fetchRequest.predicate = predicate
        try fetchedResultsController.performFetch()
        isEmpty ? delegate?.place() : delegate?.resultFound()
    }

    func fetchUncompletedTrackersFor(weekDay: String, andForDate date: String) throws {
        let predicate = predicateBuilder.buildPredicateUncompletedTrackers(forWeekDay: weekDay, andForDate: date)
        fetchedResultsController.fetchRequest.predicate = predicate
        try fetchedResultsController.performFetch()
        isEmpty ? delegate?.place() : delegate?.resultFound()
    }

    func fetchTrackersWith(name: String, forWeekDay weekDay: String) throws {
        if !name.isEmpty {
            let predicate = predicateBuilder.buildPredicateTrackersWith(name: name, forWeekDay: weekDay)
            fetchedResultsController.fetchRequest.predicate = predicate
        } else {
            let predicate = predicateBuilder.buildPredicateTrackersFor(weekDay: weekDay)
            fetchedResultsController.fetchRequest.predicate = predicate
        }
        try fetchedResultsController.performFetch()
        isEmpty ? delegate?.noResultFound() : delegate?.resultFound()
    }

    func fetchCompletedTrackersWith(name: String, forDate date: String) throws {
        if !name.isEmpty {
            let predicate = predicateBuilder.buildPredicateCompletedTrackersWith(name: name, forDate: date)
            fetchedResultsController.fetchRequest.predicate = predicate
        } else {
            let predicate = predicateBuilder.buildPredicateCompletedTrackersFor(date: date)
            fetchedResultsController.fetchRequest.predicate = predicate
        }
        try fetchedResultsController.performFetch()
        isEmpty ? delegate?.noResultFound() : delegate?.resultFound()
    }

    func fetchUncompletedTrackersWith(name: String, forWeekDay weekDay: String, andForDate date: String) throws {
        if !name.isEmpty {
            let predicate = predicateBuilder.buildPredicateUncompletedTrackersWith(name: name, forWeekDay: weekDay, andForDate: date)
            fetchedResultsController.fetchRequest.predicate = predicate
        } else {
            let predicate = predicateBuilder.buildPredicateUncompletedTrackers(forWeekDay: weekDay, andForDate: date)
            fetchedResultsController.fetchRequest.predicate = predicate
        }
        try fetchedResultsController.performFetch()
        isEmpty ? delegate?.noResultFound() : delegate?.resultFound()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension DataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedSection = IndexSet()
        deletedSection = IndexSet()
        insertedIndexes = IndexPath()
        deletedIndexes = IndexPath()
        updatedIndexes = IndexPath()
        movedIndexes = Set<DataProviderUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let insertedSectionIndexSet = insertedSection,
            let deletedSectionIndexSet = deletedSection,
            let insertedItem = insertedIndexes,
            let deletedItem = deletedIndexes,
            let updatedItem = updatedIndexes,
            let movedItem = movedIndexes else {
            return
        }
        
        let update = DataProviderUpdate(
            insertedSection: insertedSectionIndexSet,
            deletedSection: deletedSectionIndexSet,
            insertedIndexes: insertedItem,
            deletedIndexes: deletedItem,
            updatedIndexes: updatedItem,
            movedIndexes: movedItem
        )       
        // Update delegate with indexes
        delegate?.didUpdate(update)
        isEmpty ? delegate?.place() : delegate?.resultFound()
        
        insertedSection = nil
        deletedSection = nil
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        switch type {
        case .insert:
            insertedSection = IndexSet(integer: sectionIndex)
        case .delete:
            deletedSection = IndexSet(integer: sectionIndex)
        default:
            break
        }
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            insertedIndexes = newIndexPath
        case .delete:
            guard let indexPath = indexPath else { return }
            deletedIndexes = indexPath
        case .update:
            guard let indexPath = indexPath else { return }
            updatedIndexes = indexPath
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            movedIndexes?.insert(.init(oldIndexPath: indexPath, newIndexPath: newIndexPath))
        @unknown default:
            break
        }
    }
}
