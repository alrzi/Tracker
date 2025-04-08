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
    private let calendar: Calendar = .autoupdatingCurrent
    
    var numberOfCompletedTrackers: Int {
        get async throws {
            let records: [TrackerRecord] = try await persistencyService.fetchObjects(RecordObject.self)
            return records.count
        }
    }
    
    init(persistencyService: PersistencyService) {
        self.persistencyService = persistencyService
    }
    
    func createOrDeleteIfPresent(record: TrackerRecord) async throws {
        if try await isCompletedFor(selectedDay: record.date, trackerWithId: record.id) {
            let request = FetchRequestBuilder<RecordObject>()
                .setPredicate(.by(id: record.id, dateInterval: record.date.fullDayInterval()))
                .build()
            
            try await persistencyService.removeObject(for: request)
        }
        else {
            let request = FetchRequestBuilder<TrackerObject>()
                .setPredicate(.by(id: record.id))
                .build()
            
            try await persistencyService.createObject(RecordObject.self, from: record, andAddObjectFor: request)
        }
    }
    
    func fetchRecords(for sectionId: UUID, for date: Date, weekDay: WeekDay, query: String, isPinned: Bool) async throws -> [TrackerRecord] {
        let request = FetchRequestBuilder<RecordObject>()
            .setPredicate(
                query.isEmpty
                    ? .by(sectionId: sectionId, for: date.fullDayInterval(), weekDay: weekDay, isPinned: isPinned)
                    : .by(sectionId: sectionId, for: date.fullDayInterval(), weekDay: weekDay, isPinned: isPinned, query: query)
            )
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func fetchRecords(for date: Date, weekDay: WeekDay, query: String, isPinned: Bool) async throws -> [TrackerRecord] {
        let request = FetchRequestBuilder<RecordObject>()
            .setPredicate(
                query.isEmpty
                    ? .by(for: date.fullDayInterval(), weekDay: weekDay, isPinned: isPinned)
                    : .by(for: date.fullDayInterval(), weekDay: weekDay, isPinned: isPinned, query: query)
            )
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getTrackedDaysFor(id: UUID) async throws -> Int {
        let request = FetchRequestBuilder<RecordObject>()
            .setPredicate(.by(id: id))
            .build()
        
        let record: [TrackerRecord] = try await persistencyService.fetchObjects(with: request)
        
        return record.count
    }
    
    func isCompletedFor(selectedDay date: Date, trackerWithId id: UUID) async throws -> Bool {
        let request = FetchRequestBuilder<RecordObject>()
            .setPredicate(.by(id: id, dateInterval: date.fullDayInterval()))
            .build()
        
        let record: TrackerRecord? = try await persistencyService.fetchObject(with: request)
        
        return record != nil
    }
}

// MARK: - Predicates

private extension StaticPredicateBuilder where T: TrackerObject {
    static func by(id: UUID) -> Self {
        .init()
        .filter(by: \.id, value: id, comparison: .equal)
    }
}

private extension StaticPredicateBuilder where T: RecordObject {
    static func by(id: UUID) -> Self {
        .init()
        .filter(by: \.tracker.id, value: id, comparison: .equal)
    }
    
    static func by(id: UUID, dateInterval: DateInterval) -> Self {
        .by(id: id)
        .filter(by: \.date, value: dateInterval.start, comparison: .greaterThanOrEqual)
        .filter(by: \.date, value: dateInterval.end, comparison: .lessThan)
    }
    
    static func by(for dateInterval: DateInterval, weekDay: WeekDay, isPinned: Bool) -> Self {
        .init()
        .filter(by: \.tracker.isPinned, value: isPinned, comparison: .equal)
        .filter(by: \.tracker.weekDays, value: weekDay.toNumberString(), comparison: .contains)
        .filter(by: \.date, value: dateInterval.start, comparison: .greaterThanOrEqual)
        .filter(by: \.date, value: dateInterval.end, comparison: .lessThan)
    }
    
    static func by(for dateInterval: DateInterval, weekDay: WeekDay, isPinned: Bool, query: String) -> Self {
        .by(for: dateInterval, weekDay: weekDay, isPinned: isPinned)
        .filter(by: \.tracker.name, value: query, comparison: .contains)
    }
    
    static func by(sectionId: UUID, for dateInterval: DateInterval, weekDay: WeekDay, isPinned: Bool) -> Self {
        .by(for: dateInterval, weekDay: weekDay, isPinned: isPinned)
        .filter(by: \.tracker.category.id, value: sectionId, comparison: .equal)
    }
    
    static func by(sectionId: UUID, for dateInterval: DateInterval, weekDay: WeekDay, isPinned: Bool, query: String) -> Self {
        .by(sectionId: sectionId, for: dateInterval, weekDay: weekDay, isPinned: isPinned)
        .filter(by: \.tracker.name, value: query, comparison: .contains)
    }
}

extension Date {
    func fullDayInterval(calendar: Calendar = .autoupdatingCurrent) -> DateInterval {
        let startDate = calendar.startOfDay(for: self)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? self
        
        return DateInterval(start: startDate, end: endDate)
    }
}
