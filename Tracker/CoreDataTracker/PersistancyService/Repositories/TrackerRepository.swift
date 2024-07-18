//
//  TrackerRepository.swift
//  Tracker
//
//  Created by Александр Зиновьев on 17.07.2024.
//

import Foundation
import CoreData

final class TrackerRepository {
    private let persistencyService: PersistencyService
    private let predicateBuilder: PredicateBuilder
    
    init(
        persistencyService: PersistencyService,
        predicateBuilder: PredicateBuilder
    ) {
        self.persistencyService = persistencyService
        self.predicateBuilder = predicateBuilder
    }
    
    func getTracker(for id: UUID) -> [Tracker] {
        
        let trackerRequest = NSFetchRequest<TrackerObject>(entityName: TrackerObject.entityName)
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [#keyPath(TrackerObject.id), id])
        trackerRequest.predicate = predicate
        
        return persistencyService.fetchObjects(with: trackerRequest).map { Tracker(coreData: $0) }
    }
}
