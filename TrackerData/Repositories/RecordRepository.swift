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
            try await persistencyService.fetchObjects(RecordObject.self).count
        }
    }
    
    init(persistencyService: PersistencyService) {
        self.persistencyService = persistencyService
    }
    
    func createOrDeleteIfPresent(record: TrackerRecord, for trackerId: UUID) async throws {
        let request = FetchRequestBuilder<TrackerObject>
            .by(id: trackerId)
            .build()
        
        let recordRequest = FetchRequestBuilder<RecordObject>
            .by(id: record.id)
            .build()
        
        if try await persistencyService.fetchObject(with: recordRequest) != nil {
            try await persistencyService.removeObject(for: recordRequest)
        }
        else {
            try await persistencyService.createObject(RecordObject.self, from: record, andAddObjectFor: request)
        }
    }
    
    func getTrackedDaysFor(id: UUID) async throws -> Int {
        let request = FetchRequestBuilder<RecordObject>
            .by(id: id)
            .build()
        
        let recordObjects = try await persistencyService.fetchObjects(with: request)
        
        return recordObjects.count
    }
    
    func isCompletedFor(selectedDay date: Date, trackerWithId id: UUID) async throws -> Bool {
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? date
        
        let request = FetchRequestBuilder<RecordObject>
            .by(id: id, date: startDate, upTo: endDate)
            .build()
        
        let recordObject = try await persistencyService.fetchObject(with: request)
        
        return recordObject != nil
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
}

private extension FetchRequestBuilder where T: RecordObject {
    static func by(id: UUID) -> FetchRequestBuilder<T> {
        Self()
            .setPredicate(
                StaticPredicateBuilder<T>()
                    .filter(by: \.tracker.id, value: id, comparison: .equal)
                    .build()
            )
    }
    
    static func by(id: UUID, date: Date, upTo endDate: Date) -> FetchRequestBuilder<T> {
        Self()
            .setPredicate(
                StaticPredicateBuilder<T>()
                    .filter(by: \.tracker.id, value: id, comparison: .equal)
                    .filter(by: \.date, value: date, comparison: .greaterThanOrEqual)
                    .filter(by: \.date, value: endDate, comparison: .lessThan)
                    .build()
            )
    }
}
