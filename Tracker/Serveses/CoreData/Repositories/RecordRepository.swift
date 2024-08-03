//
//  RecordRepository.swift
//  Tracker
//
//  Created by Александр Зиновьев on 31.07.2024.
//

import Foundation
import CoreData.NSFetchRequest

protocol RecordRepositoryProtocol {
    var numberOfCompletedTrackers: Int { get }
    
    func getTrackedDaysFor(id: UUID) -> Int
    func removeOrAddRecordOf(tracker: Tracker, forParticularDay date: Date)
}

final class RecordRepository {
    private let persistencyService: PersistencyService
    private let predicateBuilder: PredicateBuilder
    
    init(
        persistencyService: PersistencyService,
        predicateBuilder: PredicateBuilder
    ) {
        self.persistencyService = persistencyService
        self.predicateBuilder = predicateBuilder
    }
}

extension RecordRepository: RecordRepositoryProtocol {
    var numberOfCompletedTrackers: Int {
        let objects = persistencyService.fetchObjects(RecordObject.self)
        
        return objects.count
    }
    
    func getTrackedDaysFor(id: UUID) -> Int {
        guard let objects = persistencyService.fetchObject(RecordObject.self, by: \.id, value: id) else {
            return .zero
        }
        
        return objects.count
    }
    
    func isCompletedFor(selectedDay date: Date, trackerWithId id: UUID) -> Bool {
        let predicate = predicateBuilder.buildPredicateIsCompletedFor(
            selectedDate: date,
            trackerWithId: id
        )
                
        let fetchRequest = NSFetchRequest<RecordObject>(entityName: RecordObject.entityName)
        fetchRequest.predicate = predicate
        
        return persistencyService.fetchObjects(with: fetchRequest).first != nil
    }
    
    func removeOrAddRecordOf(tracker: Tracker, forParticularDay date: Date) {
        guard let trackerObject = persistencyService.fetchObject(TrackerObject.self, by: \.id, value: tracker.id)?.first else {
            return
        }
        
        trackerObject.copy(from: tracker)
        
        let predicate = predicateBuilder.buildPredicateIsCompletedFor(
            selectedDate: date,
            trackerWithId: tracker.id
        )
                
        let fetchRequest = NSFetchRequest<RecordObject>(entityName: RecordObject.entityName)
        fetchRequest.predicate = predicate
        
        if let object = persistencyService.fetchObjects(with: fetchRequest).first {
            persistencyService.removeObject(object)
        }
        else {
            let recordObject = persistencyService.createObject(RecordObject.self)
            recordObject.date = date
            recordObject.id = tracker.id
            recordObject.tracker = trackerObject
        }
        
        persistencyService.saveContext()
    }
}
