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
    
    func createTrackerAndAddToSection(with id: UUID, tracker: Tracker) async throws {
        let requestForSection = FetchRequestBuilder<CategoryObject>()
            .setPredicate(.by(id: id))
            .build()
        
        try await persistencyService.createObject(TrackerObject.self, from: tracker, andAddObjectFor: requestForSection)
    }
    
    // MARK: - Read
    
    func getTrackers(for sectionID: UUID, isPinned: Bool, weekDay: WeekDay, query: String) async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicate(
                query.isEmpty
                ? .by(isPinned: isPinned, weekDay: weekDay, sectionID: sectionID)
                : .by(isPinned: isPinned, weekDay: weekDay, sectionID: sectionID, query: query)
            )
            .setSortDescriptors([.init(keyPath: \.name)])
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getTrackers(for sectionID: UUID, isPinned: Bool, weekDay: WeekDay, query: String, date: Date) async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicate(
                query.isEmpty
                ? .by(isPinned: isPinned, weekDay: weekDay, sectionID: sectionID, interval: date.fullDayInterval())
                : .by(isPinned: isPinned, weekDay: weekDay, sectionID: sectionID, interval: date.fullDayInterval(), query: query)
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
                : .by(isPinned: isPinned, weekDay: weekDay, interval: date.fullDayInterval(), query: query)
            )
            .setSortDescriptors([.init(keyPath: \.name)])
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getTrackers(for weekDay: WeekDay) async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>()
            .setPredicate(.by(weekDay: weekDay))
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
    
    func getTrackers() async throws -> [Tracker] {
        let request = FetchRequestBuilder<TrackerObject>()
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
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
    
    static func by(weekDay: WeekDay) -> Self {
        .init()
        .filter(by: \.weekDays, value: weekDay.toNumberString(), comparison: .contains)
    }
    
    static func by(isPinned: Bool, weekDay: WeekDay) -> Self {
        .init()
        .filter(by: \.isPinned, value: isPinned, comparison: .equal)
        .filter(by: \.weekDays, value: weekDay.toNumberString(), comparison: .contains)
    }
    
    static func by(isPinned: Bool, weekDay: WeekDay, query: String) -> Self {
        .init()
        .filter(by: \.isPinned, value: isPinned, comparison: .equal)
        .filter(by: \.weekDays, value: weekDay.toNumberString(), comparison: .contains)
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
    
    static func by(isPinned: Bool, weekDay: WeekDay, sectionID: UUID, interval: DateInterval) -> Self {
        .by(isPinned: isPinned, weekDay: weekDay, sectionID: sectionID)
        .subpredicateBetween(by: \.trackerRecord, subKeyPath: \.date, subValue1: interval.start, subValue2: interval.end)
    }
    
    static func by(isPinned: Bool, weekDay: WeekDay, sectionID: UUID, interval: DateInterval, query: String) -> Self {
        .by(isPinned: isPinned, weekDay: weekDay, sectionID: sectionID)
        .filter(by: \.name, value: query, comparison: .contains)
        .subpredicateBetween(by: \.trackerRecord, subKeyPath: \.date, subValue1: interval.start, subValue2: interval.end)
    }
    
    static func by(isPinned: Bool, weekDay: WeekDay, interval: DateInterval) -> Self {
        .by(isPinned: isPinned, weekDay: weekDay)
        .subpredicateBetween(by: \.trackerRecord, subKeyPath: \.date, subValue1: interval.start, subValue2: interval.end)
    }
    
    static func by(isPinned: Bool, weekDay: WeekDay, interval: DateInterval, query: String) -> Self {
        .by(isPinned: isPinned, weekDay: weekDay, query: query)
        .subpredicateBetween(by: \.trackerRecord, subKeyPath: \.date, subValue1: interval.start, subValue2: interval.end)
    }
}

private extension StaticPredicateBuilder where T: CategoryObject {
    static func by(id: UUID) -> Self {
        .init()
        .filter(by: \.id, value: id, comparison: .equal)
    }
}
