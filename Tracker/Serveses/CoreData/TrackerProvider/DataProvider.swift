import Foundation
import UIKit
import CoreData
import Combine

final class DataProvider: NSObject {    
    private let trackerManager: TrackerManaging
    
    private let predicateBuilder = PredicateBuilder()
    
    private let fetchedResultsController: NSFetchedResultsController<TrackerObject>
    
    private var categoriesSubject = PassthroughSubject<[TrackerSection], Never>()
    var categoriesPublisher: any Publisher<[TrackerSection], Never> { categoriesSubject }
    
    private var snapshotSubject = PassthroughSubject<NSDiffableDataSourceSnapshot<String, NSManagedObjectID>, Never>()
    var snapshotPublisher: any Publisher<NSDiffableDataSourceSnapshot<String, NSManagedObjectID>, Never> { snapshotSubject }
        
    init(
        context: NSManagedObjectContext,
        trackerManager: TrackerManaging
    ) {
        self.trackerManager = trackerManager
        
        let fetchRequest = NSFetchRequest<TrackerObject>(entityName: TrackerObject.entityName)
        fetchRequest.fetchBatchSize = 20
        fetchRequest.fetchLimit = 10
        
        let weekDay = Date().weekDayString
        fetchRequest.predicate = predicateBuilder.buildPredicateTrackersFor(weekDay: weekDay)
//        fetchRequest.predicate = predicateBuilder.buildPredicateTrackersFor(isPinned: false)
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerObject.category.title), ascending: true),
            NSSortDescriptor(key: #keyPath(TrackerObject.kind), ascending: false),
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

extension DataProvider {
    func fetch() throws {
        try fetchedResultsController.performFetch()
    }
    
    func fetchPage(page: Int) throws {
//        let fetchRequest = fetchedResultsController.fetchRequest
//        fetchRequest.fetchLimit = pageSize
//        fetchRequest.fetchOffset = page * pageSize
//        
//        try fetchedResultsController.performFetch()
    }
    
    // MARK: - Filtering
    
    func fetchTrackersWith(name: String, weekDay: String) throws {
        if !name.isEmpty {
            let predicate = predicateBuilder.buildPredicateTrackersWith(name: name, weekDay: weekDay)
            fetchedResultsController.fetchRequest.predicate = predicate
        }
        else {
            let predicate = predicateBuilder.buildPredicateTrackersFor(weekDay: weekDay)
            fetchedResultsController.fetchRequest.predicate = predicate
        }
        
        try fetchedResultsController.performFetch()
    }
    
    func fetchTrackersFor(weekDay: String) throws {
        let predicate = predicateBuilder.buildPredicateTrackersFor(weekDay: weekDay)
        fetchedResultsController.fetchRequest.predicate = predicate
        
        try fetchedResultsController.performFetch()
    }
    
    // MARK: - Completed
    
    func fetchCompletedTrackersWith(name: String, date: Date, weekDay: String) throws {
        if !name.isEmpty {
            let predicate = predicateBuilder.buildPredicateCompletedTrackersWith(name: name, date: date)
            fetchedResultsController.fetchRequest.predicate = predicate
        }
        else {
            let predicate = predicateBuilder.buildPredicateCompletedTrackersFor(date: date, weekDay: weekDay)
            fetchedResultsController.fetchRequest.predicate = predicate
        }
        try fetchedResultsController.performFetch()
    }

    func fetchCompletedTrackersFor(date: Date, weekDay: String) throws {
        let predicate = predicateBuilder.buildPredicateCompletedTrackersFor(date: date, weekDay: weekDay)
        fetchedResultsController.fetchRequest.predicate = predicate
        
        try fetchedResultsController.performFetch()
    }
    
    // MARK: - UnCompleted
    
    func fetchUncompletedTrackersWith(name: String, date: Date, weekDay: String) throws {
        if !name.isEmpty {
            let predicate = predicateBuilder.buildPredicateUncompletedTrackersWith(name: name, date: date, weekDay: weekDay)
            
            fetchedResultsController.fetchRequest.predicate = predicate
        }
        else {
            let predicate = predicateBuilder.buildPredicateUncompletedTrackersFor(date: date, weekDay: weekDay)
            fetchedResultsController.fetchRequest.predicate = predicate
        }
        
        try fetchedResultsController.performFetch()
    }

    func fetchUncompletedTrackersFor(date: Date, weekDay: String) throws {
        let predicate = predicateBuilder.buildPredicateUncompletedTrackersFor(date: date, weekDay: weekDay)
        fetchedResultsController.fetchRequest.predicate = predicate
        
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
