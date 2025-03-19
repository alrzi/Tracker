//
//  CategoryRepository.swift
//  Tracker
//
//  Created by Александр Зиновьев on 20.07.2024.
//

import Foundation
import TrackerDomain

final class CategoryRepository: CategoryRepositoryProtocol {
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
    
    func getSections(with query: String, for weekDay: String, fetchLimit: Int, fetchOffset: Int) async throws -> [TrackerSection] {
        let request = FetchRequestBuilder<CategoryObject>()
            .setPredicate(query.isEmpty ? .by(weekDay: weekDay) : .by(query: query, weekDay: weekDay))
            .setSortDescriptors([.init(keyPath: \.title)])
            .setFetchLimit(fetchLimit)
            .setFetchOffset(fetchOffset)
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getAllTrackers(with query: String) async throws -> [TrackerSection] {
        let request = FetchRequestBuilder<CategoryObject>()
            .setPredicate(.by(query: query))
            .setSortDescriptors([.init(keyPath: \.title)])
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getCategory(by id: UUID) async throws -> TrackerSection {
        let request = FetchRequestBuilder<CategoryObject>()
            .setPredicate(.by(id: id))
            .build()
        
        guard let category: TrackerSection = try await persistencyService.fetchObject(with: request) else {
            throw CategoryRepositoryError.noTrackerForId
        }
        
        return category
    }
    
    // MARK: - Update
    
    func updateCategory(_ category: TrackerSection) async throws {
        let request = FetchRequestBuilder<CategoryObject>()
            .setPredicate(.by(id: category.id))
            .build()
        
        try await persistencyService.updateObject(for: request, with: category)
    }
    
    // MARK: - Delete
    
    func deleteCategory(with id: UUID) async throws {
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
    
    static func by(weekDay: String) -> Self {
        .init()
        .subpredicate(by: \.trackers, subKeyPath: \.weekDays, subValue: weekDay, comparison: .contains)
        .subpredicate(by: \.trackers, subKeyPath: \.isPinned, subValue: false, comparison: .equal)
    }
    
    static func by(query: String) -> Self {
        .init()
        .subpredicate(by: \.trackers, subKeyPath: \.name, subValue: query, comparison: .contains)
        .subpredicate(by: \.trackers, subKeyPath: \.isPinned, subValue: false, comparison: .equal)
    }
    
    static func by(query: String, weekDay: String) -> Self {
        .by(weekDay: weekDay)
        .subpredicate(by: \.trackers, subKeyPath: \.name, subValue: query, comparison: .contains)
        .subpredicate(by: \.trackers, subKeyPath: \.isPinned, subValue: false, comparison: .equal)
    }
}
