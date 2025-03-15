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
        let requestForTracker = FetchRequestBuilder<TrackerObject>()
            .setPredicate(.by(id: id))
            .build()
        
        let requestForCategory = FetchRequestBuilder<CategoryObject>()
            .setPredicate(.by(id: id))
            .build()
        
        try await persistencyService.updateObject(for: requestForTracker, withObjectForRequest: requestForCategory)
    }
    
    // MARK: - Read
    
    func getAllTrackersForCategory(category: UUID, isPinned: Bool, weekDay: String) async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicate(.by(categoryId: category, isPinned: isPinned, weekDay: weekDay))
            .setSortDescriptors([.init(keyPath: \.name)])
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getAllTrackers(isPinned: Bool) async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicate(.by(isPinned: isPinned))
            .setSortDescriptors([.init(keyPath: \.name)])
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getAllTrackers() async throws -> [Tracker] {
        try await persistencyService.fetchObjects(TrackerObject.self)
    }
    
    func getTracker(by id: UUID) async throws -> Tracker {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicate(.by(id: id))
            .build()
        
        guard let tracker: Tracker = try await persistencyService.fetchObject(with: request) else {
            throw TrackerRepositoryError.noTrackerForId
        }
        
        return tracker
    }
    
    func isPinnedTrackersExist() async throws -> Bool {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicate(.by(isPinned: true))
            .setFetchLimit(1)
            .build()
        
        let trackers: [Tracker] = try await persistencyService.fetchObjects(with: request)
        return trackers.first != nil
    }
    
    // MARK: - Update
    
    func updateTracker(_ tracker: Tracker) async throws {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicate(.by(id: tracker.id))
            .build()
        
        try await persistencyService.updateObject(for: request, with: tracker)
    }
    
    // MARK: - Delete
    
    func deleteTracker(with id: UUID) async throws {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicate(.by(id: id))
            .build()
        
        try await persistencyService.removeObject(for: request)
    }
}

// MARK: - Predicates

private extension StaticPredicateBuilder where T: TrackerObject {
    static func by(id: UUID) -> Self {
        .init()
        .filter(by: \.id, value: id, comparison: .equal)
    }
    
    static func by(isPinned: Bool) -> Self {
        .init()
        .filter(by: \.isPinned, value: isPinned, comparison: .equal)
    }
    
    static func by(categoryId: UUID, isPinned: Bool, weekDay: String) -> Self {
        .init()
        .filter(by: \.category.id, value: categoryId)
        .filter(by: \.isPinned, value: isPinned)
        .filter(by: \.weekDays, value: weekDay, comparison: .contains)
    }
}

private extension StaticPredicateBuilder where T: CategoryObject {
    static func by(id: UUID) -> Self {
        .init()
        .filter(by: \.id, value: id, comparison: .equal)
    }
}
