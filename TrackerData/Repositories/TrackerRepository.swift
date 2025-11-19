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
        try await persistencyService.performCreate { context in
            let trackerObject: TrackerObject = context.make(TrackerObject.self)
            trackerObject.copy(from: tracker)
        }
    }

    func createTrackerAndAddToSection(with id: UUID, tracker: Tracker) async throws {
        try await persistencyService.performUpdateOrCreate { context in
            let category: CategoryObject = try context.fetchOneRaw(
                FetchRequestBuilder<CategoryObject>()
                    .setPredicates([Query(key: \.id, that: .equal(to: id))])
                    .build()
            )

            let trackerObject: TrackerObject = context.make(TrackerObject.self)
            trackerObject.copy(from: tracker)
            trackerObject.category = category
        }
    }
    
    // MARK: - Read
    
    func getTrackers(for sectionID: UUID, isPinned: Bool, weekDay: WeekDay, query: String) async throws -> [Tracker] {
        try await persistencyService.perform { context in
            try context.fetchAll(
                FetchRequestBuilder<TrackerObject>()
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
            )
        }
    }
    
    func getTrackers(for sectionID: UUID, isPinned: Bool, weekDay: WeekDay, query: String, date: Date) async throws -> [Tracker] {
        try await persistencyService.perform { context in
            try context.fetchAll(
                FetchRequestBuilder<TrackerObject>()
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
            )
        }
    }
    
    func getTrackers(isPinned: Bool, weekDay: WeekDay, query: String) async throws -> [Tracker] {
        try await persistencyService.perform { context in
            try context.fetchAll(
                FetchRequestBuilder<TrackerObject>()
                    .setPredicates(
                        [
                            Query(key: \.isPinned, that: .equal(to: isPinned)),
                            Query(key: \.weekDays, that: .contains(weekDay.toNumberString())),
                        ]
                        + (!query.isEmpty ? [Query(key: \.name, that: .contains(query))] : [])
                    )
                    .setSortDescriptors([.init(keyPath: \.name)])
                    .build()
            )
        }
    }
    
    func getTrackers(isPinned: Bool, weekDay: WeekDay, query: String, date: Date) async throws -> [Tracker] {
        try await persistencyService.perform { context in
            try context.fetchAll(
                FetchRequestBuilder<TrackerObject>()
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
            )
        }
    }
    
    func getTrackers(for weekDay: WeekDay) async throws -> [Tracker] {
        try await persistencyService.perform { context in
            try context.fetchAll(
                FetchRequestBuilder<TrackerObject>()
                    .setPredicates([
                        Query(key: \.weekDays, that: .contains(weekDay.toNumberString())),
                    ])
                    .build()
            )
        }
    }
    
    func getTrackers(id: UUID) async throws -> [Tracker] {
        try await persistencyService.perform { context in
            try context.fetchAll(
                FetchRequestBuilder<TrackerObject>()
                    .setPredicates([Query(key: \.id, that: .equal(to: id))])
                    .setSortDescriptors([.init(keyPath: \.name)])
                    .build()
            )
        }
    }
    
    func getTrackers() async throws -> [Tracker] {
        try await persistencyService.perform { context in
            try context.fetchAll(
                FetchRequestBuilder<TrackerObject>()
                    .build()
            )
        }
    }
    
    // MARK: - Update
    
    func updateTracker(_ tracker: Tracker) async throws {
        try await persistencyService.performUpdateOrCreate { context in
            let trackerObject: TrackerObject = try context.fetchOneRaw(
                FetchRequestBuilder<TrackerObject>()
                    .setPredicates([Query(key: \.id, that: .equal(to: tracker.id))])
                    .build()
            )

            let categoryObject: CategoryObject = try context.fetchOneRaw(
                FetchRequestBuilder<CategoryObject>()
                    .setPredicates([Query(key: \.id, that: .equal(to: tracker.sectionId))])
                    .build()
            )

            trackerObject.copy(from: tracker)
            trackerObject.category = categoryObject
        }
    }
    
    // MARK: - Delete
    
    func deleteTracker(with id: UUID) async throws {
       try await persistencyService.performRemove {
            $0.delete(
                try $0.fetchOneRaw(
                    FetchRequestBuilder<TrackerObject>()
                        .setPredicates([Query(key: \.id, that: .equal(to: id))])
                        .build()
                )
            )
        }
    }
}
