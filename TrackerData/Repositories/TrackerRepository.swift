//
//  TrackerRepository.swift
//  Tracker
//
//  Created by Александр Зиновьев on 17.07.2024.
//

import Foundation
import TrackerDomain

final class TrackerRepository: TrackerRepositoryProtocol {
    private let persistencyService: PersistencyService
    
    init(persistencyService: PersistencyService) {
        self.persistencyService = persistencyService
    }
    
    // MARK: - Create
    
    func createTracker(_ tracker: Tracker) async throws {
        try await persistencyService.createObject(TrackerObject.self, from: tracker)
    }
    
    func addSection(withId id: UUID, toTracker tracker: Tracker) async throws {
        let requestForTracker = FetchRequestBuilder<TrackerObject>
            .by(id: id)
            .build()
        
        let requestForCategory = FetchRequestBuilder<CategoryObject>
            .by(id: id)
            .build()
        
        try await persistencyService.updateObject(for: requestForTracker, withObjectForRequest: requestForCategory)
    }
    
    // MARK: - Read
    
    func getAllTrackersForCategory(category: UUID, isPinned: Bool, weekDay: String) async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>
            .by(categoryId: category, isPinned: isPinned, weekDay: weekDay)
            .build()
        
        let trackerObjects = try await persistencyService.fetchObjects(with: request)
        let trackers = trackerObjects.map(Tracker.init)
        
        return trackers
    }
    
    func getAllTrackers(isPinned: Bool) async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>
            .by(isPinned: isPinned)
            .build()
        
        let trackerObjects = try await persistencyService.fetchObjects(with: request)
        let trackers = trackerObjects.map(Tracker.init)
        
        return trackers
    }
    
    func getAllTrackers() async throws -> [Tracker] {
        let objects = try await persistencyService.fetchObjects(TrackerObject.self)
        let trackers = objects.map(Tracker.init)
        
        return trackers
    }
    
    func getTracker(by id: UUID) async throws -> Tracker {
        let request = FetchRequestBuilder<TrackerObject>
            .by(id: id)
            .build()
        
        guard let object = try await persistencyService.fetchObject(with: request) else {
            throw TrackerRepositoryError.noTrackerForId
        }
        
        return .init(object: object)
    }
    
    // MARK: - Update
    
    func updateTracker(_ tracker: Tracker) async throws {
        let request = FetchRequestBuilder<TrackerObject>
            .by(id: tracker.id)
            .build()
             
        try await persistencyService.updateObject(for: request, with: tracker)
    }
    
    // MARK: - Delete
    
    func deleteTracker(with id: UUID) async throws {
        let request = FetchRequestBuilder<TrackerObject>
            .by(id: id)
            .build()
       
        try await persistencyService.removeObject(for: request)
    }
}

// MARK: - Requests

private extension FetchRequestBuilder where T: TrackerObject {
    static func by(id: UUID) -> FetchRequestBuilder<T> {
        Self()
            .setPredicate(
                StaticPredicateBuilder<T>()
                    .filter(by: \.id, value: id, comparison: .equal)
                    .build()
            )
    }
    
    static func by(isPinned: Bool) -> FetchRequestBuilder<T> {
        Self()
            .setPredicate(
                StaticPredicateBuilder<T>()
                    .filter(by: \.isPinned, value: isPinned, comparison: .equal)
                    .build()
            )
    }
    
    static func by(categoryId: UUID, isPinned: Bool, weekDay: String) -> FetchRequestBuilder<T> {
        Self()
            .setPredicate(
                StaticPredicateBuilder<T>()
                    .filter(by: \.category.id, value: categoryId)
                    .filter(by: \.isPinned, value: isPinned)
                    .filter(by: \.weekDays, value: weekDay, comparison: .contains)
                    .build()
            )
            .setSortDescriptors([.init(keyPath: \T.name, ascending: false)])
    }
}

private extension FetchRequestBuilder where T: CategoryObject {
    static func by(id: UUID) -> FetchRequestBuilder<T> {
        Self()
            .setPredicate(
                StaticPredicateBuilder<T>()
                    .filter(by: \.id, value: id, comparison: .equal)
                    .build()
            )
    }
}
