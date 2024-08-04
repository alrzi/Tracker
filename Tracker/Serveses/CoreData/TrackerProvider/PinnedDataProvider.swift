//
//  PinnedDataProvider.swift
//  Tracker
//
//  Created by Александр Зиновьев on 03.08.2024.
//

import Foundation
import CoreData
import Combine
import UIKit

final class PinnedDataProvider: NSObject {
    private let trackerManager: TrackerManaging
    
    private let predicateBuilder = PredicateBuilder()
    
    private let fetchedResultsController: NSFetchedResultsController<TrackerObject>
    
    private var pinnedTrackersSubject = PassthroughSubject<[Tracker], Never>()
    var pinnedTrackersPublisher: any Publisher<[Tracker], Never> { pinnedTrackersSubject }
        
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
        fetchRequest.predicate = predicateBuilder.buildPredicateTrackersFor(isPinned: true)
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerObject.category.title), ascending: true),
            NSSortDescriptor(key: #keyPath(TrackerObject.name), ascending: true)
        ]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        
        fetchedResultsController.delegate = self
    }
    
    func fetch() throws {
        try fetchedResultsController.performFetch()
    }
}

extension PinnedDataProvider: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference
    ) {
        let coreDataSnapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        
        let trackers = coreDataSnapshot.itemIdentifiers.compactMap { trackerManager.getTrackerBy(id: $0) }

        pinnedTrackersSubject.send(trackers)
    }
}
