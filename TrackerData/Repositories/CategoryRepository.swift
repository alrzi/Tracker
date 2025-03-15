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
    
    func getAllSections(weekDay: String) async throws -> [TrackerSection] {
        let request = FetchRequestBuilder<CategoryObject>()
            .setPredicate(.by(weekDay: weekDay))
            .setSortDescriptors([.init(keyPath: \.title)])
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getCategory(by id: UUID) async throws -> TrackerSection {
        let request = FetchRequestBuilder<CategoryObject>()
            .setPredicate(.by(id: id))
            .setSortDescriptors([.init(keyPath: \.title)])
            .build()
        
        let category: TrackerSection? = try await persistencyService.fetchObject(with: request)
        
        if let category {
            return category
        }
        else {
            throw CategoryRepositoryError.noTrackerForId
        }
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
}
