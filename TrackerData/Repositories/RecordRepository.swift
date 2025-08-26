//
//  RecordRepositoryProtocol.swift
//  Tracker
//
//  Created by Александр Зиновьев on 31.07.2024.
//

import Foundation
import TrackerDomain

final class RecordRepository: RecordRepositoryProtocol {
    private let persistencyService: PersistencyService
    private let calendar: Calendar
    
    init(
        persistencyService: PersistencyService,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        self.persistencyService = persistencyService
        self.calendar = calendar
    }
    
    // Create
    
    func createOrDeleteIfPresent(record: TrackerRecord) async throws {
        let interval = record.date.fullDayInterval()
        
        if try await isCompletedFor(selectedDay: record.date, trackerWithId: record.id) {
            let request = FetchRequestBuilder<RecordObject>()
                .setPredicates(
                    [
                        Query(key: \.date, that: .between(interval.start, interval.end)),
                        Query(key: \.id, that: .equal(to: record.id))
                    ]
                )
                .build()
            
            try await persistencyService.removeObject(for: request)
        }
        else {
            let request = FetchRequestBuilder<TrackerObject>()
                .setPredicates([Query(key: \.id, that: .equal(to: record.id))])
                .build()
            
            try await persistencyService.createObject(RecordObject.self, from: record, andAddObjectFor: request)
        }
    }
    
    // Read
    
    func fetchRecords() async throws -> [TrackerRecord] {
        let request = FetchRequestBuilder<RecordObject>()
            .setSortDescriptors([.init(keyPath: \.date)])
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func fetchRecords(for sectionId: UUID, for date: Date, weekDay: WeekDay, query: String, isPinned: Bool) async throws -> [TrackerRecord] {
        let interval = date.fullDayInterval()
        
        let request = FetchRequestBuilder<RecordObject>()
            .setPredicates(
                [
                    Query(key: \.date, that: .between(interval.start, interval.end)),
                    Query(key: \.tracker.isPinned, that: .equal(to: isPinned)),
                    Query(key: \.tracker.weekDays, that: .contains(weekDay.toNumberString())),
                    Query(key: \.tracker.category.id, that: .equal(to: sectionId)),
                ]
                + (!query.isEmpty ? [Query(key: \.tracker.name, that: .contains(query))] : [])
            )
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func fetchRecords(for date: Date, weekDay: WeekDay, query: String, isPinned: Bool) async throws -> [TrackerRecord] {
        let interval = date.fullDayInterval()
        
        let request = FetchRequestBuilder<RecordObject>()
            .setPredicates(
                [
                    Query(key: \.date, that: .between(interval.start, interval.end)),
                    Query(key: \.tracker.isPinned, that: .equal(to: isPinned)),
                    Query(key: \.tracker.weekDays, that: .contains(weekDay.toNumberString())),
                ]
                + (!query.isEmpty ? [Query(key: \.tracker.name, that: .contains(query))] : [])
            )
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getTrackedDaysFor(id: UUID) async throws -> Int {
        let request = FetchRequestBuilder<RecordObject>()
            .setPredicates([Query(key: \.id, that: .equal(to: id))])
            .build()
        
        return try await persistencyService.fetchCount(with: request)
    }
    
    func getCompletedTrackersCount() async throws -> Int {
        let request = FetchRequestBuilder<RecordObject>()
            .build()
        
        return try await persistencyService.fetchCount(with: request)
    }
    
    func isCompletedFor(selectedDay date: Date, trackerWithId id: UUID) async throws -> Bool {
        let interval = date.fullDayInterval()
        
        let request = FetchRequestBuilder<RecordObject>()
            .setPredicates(
                [
                    Query(key: \.id, that: .equal(to: id)),
                    Query(key: \.date, that: .between(interval.start, interval.end)),
                ]
            )
            .build()
        
        return try await persistencyService.fetchCount(with: request) != .zero
    }
}
