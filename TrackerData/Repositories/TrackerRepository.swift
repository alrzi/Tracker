//
//  TrackerRepository.swift
//  Tracker
//
//  Created by Александр Зиновьев on 17.07.2024.
//

import Foundation
import CoreData.NSFetchRequest
import TrackerDomain

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
}
 
extension TrackerRepository: TrackerRepositoryProtocol {
    func createTracker(_ tracker: Tracker) async {
        let object = await persistencyService.createObject(TrackerObject.self)
        object.copy(from: tracker)
        
        await persistencyService.saveContext()
    }
    
    func getAllTrackers(isPinned: Bool) async throws -> [Tracker] {
        let fetchRequest = NSFetchRequest<TrackerObject>(entityName: TrackerObject.entityName)
        fetchRequest.predicate = predicateBuilder.buildPredicateTrackersFor(isPinned: isPinned)
        
        let objects = try await persistencyService.fetchObjects(with: fetchRequest)
        let trackers = objects.map(Tracker.init)
        return trackers
    }
    
    func getAllTrackers() async throws -> [Tracker] {
        let objects = try await persistencyService.fetchObjects(TrackerObject.self)
        let trackers = objects.map(Tracker.init)
        return trackers
    }
    
    func getTracker(by id: UUID) async throws -> Tracker {
        let fetchRequest = NSFetchRequest<TrackerObject>(entityName: TrackerObject.entityName)
        fetchRequest.predicate = predicateBuilder.buildPredicateTrackerId(id: id)
        
        guard let object = try await persistencyService.fetchObject(with: fetchRequest) else {
            throw TrackerRepositoryError.noTrackerForId
        }
        
        return .init(object: object)
    }        
    
    func updateTracker(_ tracker: Tracker) async throws {
        let fetchRequest = NSFetchRequest<TrackerObject>(entityName: TrackerObject.entityName)
        fetchRequest.predicate = predicateBuilder.buildPredicateTrackerId(id: tracker.id)
        
        guard let object = try await persistencyService.fetchObject(with: fetchRequest) else {
            throw TrackerRepositoryError.noTrackerForId
        }
        
        object.copy(from: tracker)
        
        await persistencyService.saveContext()
    }
    
    func deleteTracker(with id: UUID) async throws {
        let fetchRequest = NSFetchRequest<TrackerObject>(entityName: TrackerObject.entityName)
        fetchRequest.predicate = predicateBuilder.buildPredicateTrackerId(id: id)
        
        guard let object = try await persistencyService.fetchObject(with: fetchRequest) else {
            throw TrackerRepositoryError.noTrackerForId
        }
        
        await persistencyService.removeObject(object)
        await persistencyService.saveContext()
    }
    
    func addCategory(withId id: UUID, toTracker tracker: Tracker) async throws {
        let fetchRequestCategory = NSFetchRequest<CategoryObject>(entityName: CategoryObject.entityName)
        fetchRequestCategory.predicate = predicateBuilder.buildPredicateTrackerId(id: id)
        
        guard let categoryObject = try await persistencyService.fetchObject(with: fetchRequestCategory) else {
            throw TrackerRepositoryError.noCategoryForId
        }
        
        let fetchRequest = NSFetchRequest<TrackerObject>(entityName: TrackerObject.entityName)
        fetchRequest.predicate = predicateBuilder.buildPredicateTrackerId(id: id)
        
        guard let object = try await persistencyService.fetchObject(with: fetchRequest) else {
            throw TrackerRepositoryError.noTrackerForId
        }
        
        let trackerObject = await persistencyService.createObject(TrackerObject.self)
        trackerObject.copy(from: tracker)
        trackerObject.category = categoryObject
        
        await persistencyService.saveContext()
    }
    
    func addPrepared(sections: [TrackerSection]) {
        for section in sections {
            let sectionObject = persistencyService.createObject(CategoryObject.self)
            sectionObject.copy(from: section)
            
            section.trackers.forEach { tracker in
                let trackerObject = persistencyService.createObject(TrackerObject.self)
                trackerObject.copy(from: tracker)
                
                sectionObject.addToTrackers(trackerObject)
            }
        }
        
        persistencyService.saveContext()
    }
}
