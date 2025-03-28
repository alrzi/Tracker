//
//  TrackerRepository.swift
//  Tracker
//
//  Created by Александр Зиновьев on 17.07.2024.
//

import Foundation
import TrackerDomain
import CoreData

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
    
    func getTrackers(for category: UUID, isPinned: Bool, weekDay: WeekDay, query: String) async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicate(
                query.isEmpty
                    ? .by(isPinned: isPinned, weekDay: weekDay, sectionID: category)
                    : .by(isPinned: isPinned, weekDay: weekDay, sectionID: category, query: query)
            )
            .setSortDescriptors([.init(keyPath: \.name)])
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getTrackers(for category: UUID, isPinned: Bool, weekDay: WeekDay, query: String, date: Date) async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicate(
                query.isEmpty
                    ? .by(isPinned: isPinned, weekDay: weekDay, sectionID: category, interval: date.fullDayInterval())
                    : .by(isPinned: isPinned, weekDay: weekDay, sectionID: category, query: query, interval: date.fullDayInterval())
            )
            .setSortDescriptors([.init(keyPath: \.name)])
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getTrackers(isPinned: Bool, weekDay: WeekDay, query: String) async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicate(
                query.isEmpty
                    ? .by(isPinned: isPinned, weekDay: weekDay)
                    : .by(isPinned: isPinned, weekDay: weekDay, query: query)
            )
            .setSortDescriptors([.init(keyPath: \.name)])
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getTrackers(isPinned: Bool, weekDay: WeekDay, query: String, date: Date) async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicate(
                query.isEmpty
                    ? .by(isPinned: isPinned, weekDay: weekDay, interval: date.fullDayInterval())
                    : .by(isPinned: isPinned, weekDay: weekDay, query: query, interval: date.fullDayInterval())
            )
            .setSortDescriptors([.init(keyPath: \.name)])
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getTrackers(id: UUID) async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicate(.by(id: id))
            .setSortDescriptors([.init(keyPath: \.name)])
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func isPinnedTrackersExist() async throws -> Bool {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicate(.by(isPinned: true))
            .setFetchLimit(1)
            .build()
        
        return try await persistencyService.fetchCount(with: request) > 0
    }
    
    func isPinnedTrackersExist(with name: String) async throws -> Bool {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicate(.by(isPinned: true, query: name))
            .setFetchLimit(1)
            .build()
                
        return try await persistencyService.fetchCount(with: request) > 0
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
    
    static func by(id: UUID, isPinned: Bool) -> Self {
        .init()
        .filter(by: \.id, value: id, comparison: .equal)
        .filter(by: \.isPinned, value: isPinned, comparison: .equal)
    }
    
    static func by(isPinned: Bool) -> Self {
        .init()
        .filter(by: \.isPinned, value: isPinned, comparison: .equal)
    }
    
    static func by(isPinned: Bool, query: String) -> Self {
        .by(isPinned: isPinned)
        .filter(by: \.name, value: query, comparison: .contains)
    }
    
    static func by(isPinned: Bool, weekDay: WeekDay) -> Self {
        .init()
        .filter(by: \.isPinned, value: isPinned, comparison: .equal)
        .filter(by: \.weekDays, value: Set([weekDay.rawValue]), comparison: .contains)
    }
    
    static func by(isPinned: Bool, weekDay: WeekDay, query: String) -> Self {
        .by(isPinned: isPinned, weekDay: weekDay)
        .filter(by: \.name, value: query, comparison: .contains)
    }
    
    static func by(isPinned: Bool, weekDay: WeekDay, sectionID: UUID) -> Self {
        .by(isPinned: isPinned, weekDay: weekDay)
        .filter(by: \.category.id, value: sectionID, comparison: .equal)
    }
    
    static func by(isPinned: Bool, weekDay: WeekDay, sectionID: UUID, query: String) -> Self {
        .by(isPinned: isPinned, weekDay: weekDay, sectionID: sectionID)
        .filter(by: \.name, value: query, comparison: .contains)
    }
    
    static func by(isPinned: Bool, weekDay: WeekDay, sectionID: UUID, query: String, interval: DateInterval) -> Self {
        .by(isPinned: isPinned, weekDay: weekDay, sectionID: sectionID)
        .filter(by: \.name, value: query, comparison: .contains)
        .subpredicateBetween(by: \.trackerRecord, subKeyPath: \.date, subValue1: interval.start, subValue2: interval.end)
    }
    
    static func by(isPinned: Bool, weekDay: WeekDay, sectionID: UUID, interval: DateInterval) -> Self {
        .by(isPinned: isPinned, weekDay: weekDay, sectionID: sectionID)
        .subpredicateBetween(by: \.trackerRecord, subKeyPath: \.date, subValue1: interval.start, subValue2: interval.end)
    }
    
    static func by(isPinned: Bool, weekDay: WeekDay, query: String, interval: DateInterval) -> Self {
        .by(isPinned: isPinned, weekDay: weekDay, query: query)
        .filter(by: \.name, value: query, comparison: .contains)
        .subpredicateBetween(by: \.trackerRecord, subKeyPath: \.date, subValue1: interval.start, subValue2: interval.end)
    }
    
    static func by(isPinned: Bool, weekDay: WeekDay, interval: DateInterval) -> Self {
        .by(isPinned: isPinned, weekDay: weekDay)
        .subpredicateBetween(by: \.trackerRecord, subKeyPath: \.date, subValue1: interval.start, subValue2: interval.end)
    }
}

private extension StaticPredicateBuilder where T: CategoryObject {
    static func by(id: UUID) -> Self {
        .init()
        .filter(by: \.id, value: id, comparison: .equal)
    }
}
