import Foundation
import UIKit
import CoreData
import Combine


protocol DataProviderProtocol {
    typealias Snapshot = NSDiffableDataSourceSnapshot<TrackersDataSource.Section, TrackersDataSource.SectionItem>
    
    var snapshotPublisher: any Publisher<Snapshot, Never> { get }
    
    func fetch() throws
    func getTracker(at id: NSManagedObjectID) -> Tracker?
    
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
    typealias Snapshot = NSDiffableDataSourceSnapshot<TrackersDataSource.Section, TrackersDataSource.SectionItem>
    
    private let trackerStore: TrackerStoreManagerProtocol
    private let trackerRecordStore: TrackerRecordStoreProtocol
    
    private let predicateBuilder: TrackerPredicateBuilderProtocol = PredicateBuilder()
    
    private let fetchedResultsController: NSFetchedResultsController<TrackerObject>
    
    private var snapshotSubject = PassthroughSubject<Snapshot, Never>()
    var snapshotPublisher: any Publisher<Snapshot, Never> { snapshotSubject }
        
    init(
        context: NSManagedObjectContext,
        trackerStore: TrackerStore,
        trackerRecordStore: TrackerRecordStore
    ) {
        self.trackerStore = trackerStore
        self.trackerRecordStore = trackerRecordStore        
        
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

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerObject.category.title),
            cacheName: nil
        )
        
        super.init()
        
        fetchedResultsController.delegate = self
    }
}

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {
    func fetch() throws {
        try fetchedResultsController.performFetch()
    }
    
    func getTracker(at id: NSManagedObjectID) -> Tracker? {
        guard let object = trackerStore.object(TrackerObject.self, with: id) else {
            return nil
        }
        
        return .init(object: object)
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
        } 
        catch {
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
    }

    func fetchCompletedTrackersFor(date: String) throws {
        let predicate = predicateBuilder.buildPredicateCompletedTrackersFor(date: date)
        fetchedResultsController.fetchRequest.predicate = predicate
        try fetchedResultsController.performFetch()
        
    }

    func fetchUncompletedTrackersFor(weekDay: String, andForDate date: String) throws {
        let predicate = predicateBuilder.buildPredicateUncompletedTrackers(forWeekDay: weekDay, andForDate: date)
        fetchedResultsController.fetchRequest.predicate = predicate
        try fetchedResultsController.performFetch()        
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
    }
}

extension DataProvider: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference
    ) {
        let coreDataSnapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        var newEmptySnapshot = Snapshot()
        
        for sectionIdentifier in coreDataSnapshot.sectionIdentifiers {
            newEmptySnapshot.appendSections([.section(sectionIdentifier)])
            let itemIdentifiers = coreDataSnapshot.itemIdentifiers(inSection: sectionIdentifier)
            newEmptySnapshot.appendItems(itemIdentifiers.map { .tracker($0) }, toSection: .section(sectionIdentifier))
        }

        snapshotSubject.send(newEmptySnapshot)
    }
}
