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
            try await persistencyService.performRemove {
                $0.delete(
                    try $0.fetchOneRaw(
                        FetchRequestBuilder<RecordObject>()
                            .setPredicates(
                                [
                                    Query(key: \.date, that: .between(interval.start, interval.end)),
                                    Query(key: \.id, that: .equal(to: record.id))
                                ]
                            )
                            .build()
                    )
                )
            }
        }
        else {
            try await persistencyService.performUpdateOrCreate { context in
                let trackerObject: TrackerObject = try context.fetchOneRaw(
                    FetchRequestBuilder<TrackerObject>()
                        .setPredicates([Query(key: \.id, that: .equal(to: record.id))])
                        .build()
                )

                let recordObject: RecordObject = context.make(RecordObject.self)
                recordObject.copy(from: record)
                recordObject.tracker = trackerObject
            }
        }
    }
    
    // Read
    
    func fetchRecords() async throws -> [TrackerRecord] {
        try await persistencyService.perform { context in
            try context.fetchAll(
                FetchRequestBuilder<RecordObject>()
                    .setSortDescriptors([.init(keyPath: \.date)])
                    .build()
            )
        }
    }
    
    func fetchRecords(for sectionId: UUID, for date: Date, weekDay: WeekDay, query: String, isPinned: Bool) async throws -> [TrackerRecord] {
        try await persistencyService.perform { context in
            let interval = date.fullDayInterval()

            return try context.fetchAll(
                FetchRequestBuilder<RecordObject>()
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
            )
        }
    }
    
    func fetchRecords(for date: Date, weekDay: WeekDay, query: String, isPinned: Bool) async throws -> [TrackerRecord] {
        try await persistencyService.perform { context in
            let interval = date.fullDayInterval()

            return try context.fetchAll(
                FetchRequestBuilder<RecordObject>()
                    .setPredicates(
                        [
                            Query(key: \.date, that: .between(interval.start, interval.end)),
                            Query(key: \.tracker.isPinned, that: .equal(to: isPinned)),
                            Query(key: \.tracker.weekDays, that: .contains(weekDay.toNumberString())),
                        ]
                        + (!query.isEmpty ? [Query(key: \.tracker.name, that: .contains(query))] : [])
                    )
                    .build()
            )
        }
    }
    
    func getTrackedDaysFor(id: UUID) async throws -> Int {
        try await persistencyService.performCount { context in
            try context.fetchCount(
                FetchRequestBuilder<RecordObject>()
                    .setPredicates([Query(key: \.id, that: .equal(to: id))])
                    .build()
            )
        }
    }
    
    func getCompletedTrackersCount() async throws -> Int {
        try await persistencyService.performCount { context in
            try context.fetchCount(
                FetchRequestBuilder<RecordObject>()
                    .build()
            )
        }
    }
    
    func isCompletedFor(selectedDay date: Date, trackerWithId id: UUID) async throws -> Bool {
        try await persistencyService.performCount { context in
            let interval = date.fullDayInterval()

            return try context.fetchCount(
                FetchRequestBuilder<RecordObject>()
                    .setPredicates(
                        [
                            Query(key: \.id, that: .equal(to: id)),
                            Query(key: \.date, that: .between(interval.start, interval.end)),
                        ]
                    )
                    .build()
            )
        } != .zero
    }
}
