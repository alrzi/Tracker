//
//  TrackerRepository.swift
//  Tracker
//
//  Created by Александр Зиновьев on 17.07.2024.
//

import Foundation
import CoreData.NSManagedObjectID

enum TrackerRepositoryError: Error {
    case noTrackerForId
    case noCategoryForId
}

protocol TrackerRepositoryProtocol {
    func createTracker(_ tracker: Tracker)
    func getAllTrackers()
    func getTracker(by id: UUID) throws -> Tracker
    func updateTracker(_ tracker: Tracker) throws
    func deleteTracker(with id: UUID) throws
}

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
    
    func createTracker(_ tracker: Tracker) {
        let object = persistencyService.createObject(TrackerObject.self)
        object.copy(from: tracker)
        
        persistencyService.saveContext()
    }
    
    func addCategory(withId id: UUID, toTracker tracker: Tracker) throws {
        guard let categoryObject = persistencyService.fetchObject(CategoryObject.self, by: \.id, value: id)?.first else {
            throw TrackerRepositoryError.noCategoryForId
        }
        
        let trackerObject = persistencyService.createObject(TrackerObject.self)
        trackerObject.copy(from: tracker)
        trackerObject.category = categoryObject
        
        persistencyService.saveContext()
    }
    
    func getAllTrackers() -> [Tracker] {
        let objects = persistencyService.fetchObjects(TrackerObject.self)
        let trackers = objects.map(Tracker.init)
        return trackers
    }
    
    func getTracker(by id: UUID) throws -> Tracker {
        guard let object = persistencyService.fetchObject(TrackerObject.self, by: \.id, value: id)?.first else {
            throw TrackerRepositoryError.noTrackerForId
        }
        
        return .init(object: object)
    }
    
    func getTracker(by managedObjectID: NSManagedObjectID) -> Tracker? {
        guard let object = persistencyService.object(TrackerObject.self, with: managedObjectID) else {
            return nil
        }
        
        return .init(object: object)
    }
    
    func updateTracker(_ tracker: Tracker) throws {
        guard let object = persistencyService.fetchObject(TrackerObject.self, by: \.id, value: tracker.id)?.first else {
            throw TrackerRepositoryError.noTrackerForId
        }
        
        object.copy(from: tracker)        
        
        persistencyService.saveContext()
    }
    
    func deleteTracker(with id: UUID) throws {
        guard let object = persistencyService.fetchObject(TrackerObject.self, by: \.id, value: id)?.first else {
            throw TrackerRepositoryError.noTrackerForId
        }
        
        persistencyService.removeObject(object)
        
        persistencyService.saveContext()
    }
}
