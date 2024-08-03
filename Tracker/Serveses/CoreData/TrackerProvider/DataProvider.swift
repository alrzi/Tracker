import Foundation
import UIKit
import CoreData
import Combine

final class DataProvider: NSObject {    
    private let trackerManager: TrackerManaging
    
    private let predicateBuilder: TrackerPredicateBuilderProtocol = PredicateBuilder()
    
    private let fetchedResultsController: NSFetchedResultsController<TrackerObject>
    
    private var categoriesSubject = PassthroughSubject<[TrackerSection], Never>()
    var categoriesPublisher: any Publisher<[TrackerSection], Never> { categoriesSubject }
        
    init(
        context: NSManagedObjectContext,
        trackerManager: TrackerManaging
    ) {
        self.trackerManager = trackerManager
        
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

extension DataProvider: DataProviding {
    func fetch() throws {
        try fetchedResultsController.performFetch()
    }
    
    // MARK: - Filtering
    
    func fetchTrackersFor(weekDay: String) throws {
        let predicate = predicateBuilder.buildPredicateTrackersFor(weekDay: weekDay)
        fetchedResultsController.fetchRequest.predicate = predicate
        try fetchedResultsController.performFetch()
    }

    func fetchCompletedTrackersFor(date: Date) throws {
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
        } 
        else {
            let predicate = predicateBuilder.buildPredicateTrackersFor(weekDay: weekDay)
            fetchedResultsController.fetchRequest.predicate = predicate
        }
        
        try fetchedResultsController.performFetch()
    }

    func fetchCompletedTrackersWith(name: String, forDate date: Date) throws {
        if !name.isEmpty {
            let predicate = predicateBuilder.buildPredicateCompletedTrackersWith(name: name, forDate: date)
            fetchedResultsController.fetchRequest.predicate = predicate
        } 
        else {
            let predicate = predicateBuilder.buildPredicateCompletedTrackersFor(date: date)
            fetchedResultsController.fetchRequest.predicate = predicate
        }
        try fetchedResultsController.performFetch()
    }

    func fetchUncompletedTrackersWith(name: String, forWeekDay weekDay: String, andForDate date: String) throws {
        if !name.isEmpty {
            let predicate = predicateBuilder.buildPredicateUncompletedTrackersWith(
                name: name,
                forWeekDay: weekDay,
                andForDate: date
            )
            
            fetchedResultsController.fetchRequest.predicate = predicate
        } 
        else {
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
                
        var sections: [TrackerSection] = []
        
        for sectionIdentifier in coreDataSnapshot.sectionIdentifiers {
            let itemIdentifiers = coreDataSnapshot.itemIdentifiers(inSection: sectionIdentifier)
            
            let trackers = itemIdentifiers.compactMap { trackerManager.getTrackerBy(id: $0) }
            
            sections.append(.init(title: sectionIdentifier, trackers: trackers))
        }

        categoriesSubject.send(sections)
    }
}
