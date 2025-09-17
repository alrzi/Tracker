//
//  TrackerRepository.swift
//  Tracker
//
//  Created by Александр Зиновьев on 17.07.2024.
//

import Foundation
import TrackerDomain
import Combine

final class TrackerRepository: TrackerRepositoryProtocol {
    private let persistencyService: PersistencyService
    
    init(persistencyService: PersistencyService) {
        self.persistencyService = persistencyService
    }
    
    func observe(changes: Set<ChangeType>) -> AsyncPublisher<Publishers.CompactMap<NotificationCenter.Publisher, Set<ChangeType>>> {
        persistencyService.observe(changes)
    }
    
    // MARK: - Create
    
    func createTracker(_ tracker: Tracker) async throws {
        try await persistencyService.createObject(TrackerObject.self, from: tracker)
    }
    
    func createTrackerAndAddToSection(with id: UUID, tracker: Tracker) async throws {
        let requestForSection = FetchRequestBuilder<CategoryObject>()
            .setPredicates([Query(key: \.id, that: .equal(to: id))])
            .build()
        
        try await persistencyService.createObject(TrackerObject.self, from: tracker, andAddObjectFor: requestForSection)
    }
    
    // MARK: - Read
    
    func getTrackers(for sectionID: UUID, isPinned: Bool, weekDay: WeekDay, query: String) async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicates(
                [
                    Query(key: \.isPinned, that: .equal(to: isPinned)),
                    Query(key: \.weekDays, that: .contains(weekDay.toNumberString())),
                    Query(key: \.category.id, that: .equal(to: sectionID)),
                ]
                + (!query.isEmpty ? [Query(key: \TrackerObject.name, that: .contains(query))] : [])
            )
            .setSortDescriptors([.init(keyPath: \.name)])
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getTrackers(for sectionID: UUID, isPinned: Bool, weekDay: WeekDay, query: String, date: Date) async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicates(
                [
                    Query(key: \.isPinned, that: .equal(to: isPinned)),
                    Query(key: \.weekDays, that: .contains(weekDay.toNumberString())),
                    Query(key: \.category.id, that: .equal(to: sectionID)),
                    SubQuery(key: \.trackerRecord, subKey: \.date, that: .between(date.fullDayInterval().start, date.fullDayInterval().end), isMore: false),
                ]
                + (!query.isEmpty ? [Query(key: \TrackerObject.name, that: .contains(query))] : [])
            )
            .setSortDescriptors([.init(keyPath: \.name)])
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getTrackers(isPinned: Bool, weekDay: WeekDay, query: String) async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicates(
                [
                    Query(key: \.isPinned, that: .equal(to: isPinned)),
                    Query(key: \.weekDays, that: .contains(weekDay.toNumberString())),
                ]
                + (!query.isEmpty ? [Query(key: \.name, that: .contains(query))] : [])
            )
            .setSortDescriptors([.init(keyPath: \.name)])
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getTrackers(isPinned: Bool, weekDay: WeekDay, query: String, date: Date) async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicates(
                [
                    Query(key: \.isPinned, that: .equal(to: isPinned)),
                    Query(key: \.weekDays, that: .contains(weekDay.toNumberString())),
                    SubQuery(key: \.trackerRecord, subKey: \.date, that: .between(date.fullDayInterval().start, date.fullDayInterval().end), isMore: false),
                ]
                + (!query.isEmpty ? [Query(key: \.name, that: .contains(query))] : [])
            )
            .setSortDescriptors([.init(keyPath: \.name)])
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getTrackers(for weekDay: WeekDay) async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicates([
                Query(key: \.weekDays, that: .contains(weekDay.toNumberString())),
            ])
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getTrackers(id: UUID) async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicates([Query(key: \.id, that: .equal(to: id))])
            .setSortDescriptors([.init(keyPath: \.name)])
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getTrackers() async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>()
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    // MARK: - Update
    
    func updateTracker(_ tracker: Tracker) async throws {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicates([Query(key: \.id, that: .equal(to: tracker.id))])
            .build()
        
        let sectionRequest = FetchRequestBuilder<CategoryObject>()
            .setPredicates([Query(key: \.id, that: .equal(to: tracker.sectionId))])
            .build()
        
        try await persistencyService.updateObject(for: request, with: tracker, addEntityForRequest: sectionRequest)
    }
    
    // MARK: - Delete
    
    func deleteTracker(with id: UUID) async throws {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicates([Query(key: \.id, that: .equal(to: id))])
            .build()
        
        try await persistencyService.removeObject(for: request)
    }
}
