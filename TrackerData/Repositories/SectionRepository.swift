//
//  SectionRepository.swift
//  Tracker
//
//  Created by Александр Зиновьев on 20.07.2024.
//

import Foundation
import TrackerDomain

private enum SectionRepositoryError: Error {
    case noTrackerForId
}

final class SectionRepository: SectionRepositoryProtocol {
    private let persistencyService: PersistencyService
    
    init(persistencyService: PersistencyService) {
        self.persistencyService = persistencyService
    }
    
    // MARK: - Create
    
    func createSection(_ section: TrackerSection) async throws {
        try await persistencyService.createObject(CategoryObject.self, from: section)
    }
    
    func createSections(_ sections: [TrackerSection]) async throws {
        for section in sections {
            try await persistencyService.createObjectAndAddToEntity(
                TrackerObject.self,
                from: section.trackers,
                CategoryObject.self,
                entityToAddTo: section
            )
        }
    }
    
    // MARK: - Read
    
    func getSections(fetchLimit: Int, fetchOffset: Int) async throws -> [TrackerSection] {
        let request = FetchRequestBuilder<CategoryObject>()
            .setSortDescriptors([.init(keyPath: \.title)])
            .setFetchLimit(fetchLimit)
            .setFetchOffset(fetchOffset)
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getSections(params: RequestParameters) async throws -> [TrackerSection] {
        let request = FetchRequestBuilder<CategoryObject>()
            .setPredicate(
                params.query.isEmpty
                ? .by(weekDay: params.weekDay)
                : .by(weekDay: params.weekDay, query: params.query)
            )
            .setSortDescriptors([.init(keyPath: \.title)])
            .setFetchLimit(params.fetchLimit)
            .setFetchOffset(params.fetchOffset)
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getSections(params: RequestParameters, isCompleted: Bool) async throws -> [TrackerSection] {
        let interval = params.currentDate.fullDayInterval()
        
        let request = FetchRequestBuilder<CategoryObject>()
            .setPredicate(
                params.query.isEmpty
                ? .byComp(weekDay: params.weekDay, interval: interval, isCompleted: isCompleted)
                : .byComp(weekDay: params.weekDay, interval: interval, isCompleted: isCompleted, query: params.query)
            )
            .setSortDescriptors([.init(keyPath: \.title)])
            .setFetchLimit(params.fetchLimit)
            .setFetchOffset(params.fetchOffset)
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getSection(by id: UUID) async throws -> TrackerSection {
        let request = FetchRequestBuilder<CategoryObject>()
            .setPredicate(.by(id: id))
            .build()
        
        guard let section: TrackerSection = try await persistencyService.fetchObject(with: request) else {
            throw SectionRepositoryError.noTrackerForId
        }
        
        return section
    }
    
    // MARK: - Update
    
    func updateSection(_ section: TrackerSection) async throws {
        let request = FetchRequestBuilder<CategoryObject>()
            .setPredicate(.by(id: section.id))
            .build()
        
        try await persistencyService.updateObject(for: request, with: section)
    }
    
    // MARK: - Delete
    
    func deleteSection(with id: UUID) async throws {
        let request = FetchRequestBuilder<CategoryObject>()
            .setPredicate(.by(id: id))
            .build()
        
        try await persistencyService.removeObject(for: request)
    }
    
    func deleteAll() async throws {
        try await persistencyService.deleteAllObjects(CategoryObject.self)
    }
}

// MARK: - Predicates

private extension StaticPredicateBuilder where T: CategoryObject {
    static func by(id: UUID) -> Self {
        .init()
        .filter(by: \.id, value: id, comparison: .equal)
    }
    
    static func by(weekDay: WeekDay) -> Self {
        .init()
        .subpredicate(by: \.trackers, subKeyPath: \.weekDays, subValue: weekDay.toNumberString(), comparison: .contains)
        .subpredicate(by: \.trackers, subKeyPath: \.isPinned, subValue: false, comparison: .equal)
    }
    
    static func by(query: String) -> Self {
        .init()
        .subpredicate(by: \.trackers, subKeyPath: \.name, subValue: query, comparison: .contains)
        .subpredicate(by: \.trackers, subKeyPath: \.isPinned, subValue: false, comparison: .equal)
    }
    
    static func by(weekDay: WeekDay, query: String) -> Self {
        .by(weekDay: weekDay)
        .subpredicate(by: \.trackers, subKeyPath: \.name, subValue: query, comparison: .contains)
        .subpredicate(by: \.trackers, subKeyPath: \.isPinned, subValue: false, comparison: .equal)
    }
    
    static func byComp(weekDay: WeekDay, interval: DateInterval, isCompleted: Bool) -> Self {
        .init()
        .subpredicate(by: \.trackers, subKeyPath: \.weekDays, subValue: weekDay.toNumberString(), comparison: .contains)
        .subpredicateInSubpredicate(by: \.trackers, subKeyPath: \.trackerRecord, terKeyPath: \.date, subValue1: interval.start, subValue2: interval.end, isMore: isCompleted)
    }
    
    static func byComp(weekDay: WeekDay, interval: DateInterval, isCompleted: Bool, query: String) -> Self {
        .by(weekDay: weekDay)
        .subpredicate(by: \.trackers, subKeyPath: \.name, subValue: query, comparison: .contains)
        .subpredicateInSubpredicate(by: \.trackers, subKeyPath: \.trackerRecord, terKeyPath: \.date, subValue1: interval.start, subValue2: interval.end, isMore: isCompleted)
    }
}
