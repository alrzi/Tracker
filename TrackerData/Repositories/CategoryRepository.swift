//
//  CategoryRepository.swift
//  Tracker
//
//  Created by Александр Зиновьев on 20.07.2024.
//

import Foundation
import TrackerDomain
import CoreData.NSFetchRequest

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
        let request = FetchRequestBuilder<CategoryObject>
            .by(weekDay: weekDay)
            .build()
        
        let objects = try await persistencyService.fetchObjects(with: request)
        let categories = objects.map(TrackerSection.init)
        return categories
    }
    
    func getCategory(by id: UUID) async throws -> TrackerSection {
        let request = FetchRequestBuilder<CategoryObject>
            .by(id: id)
            .build()
        
        guard let object = try await persistencyService.fetchObject(with: request) else {
            throw CategoryRepositoryError.noTrackerForId
        }
        
        return .init(id: object.id, title: object.title, trackers: [])
    }
    
    // MARK: - Update
    
    func updateCategory(_ category: TrackerSection) async throws {
        let request = FetchRequestBuilder<CategoryObject>
            .by(id: category.id)
            .build()
        
        try await persistencyService.updateObject(for: request, with: category)
    }
    
    // MARK: - Delete
    
    func deleteCategory(with id: UUID) async throws {
        let request = FetchRequestBuilder<CategoryObject>
            .by(id: id)
            .build()
        
        try await persistencyService.removeObject(for: request)
    }
    
    func deleteAll() async throws {
        try await persistencyService.deleteAllObjects(CategoryObject.self)
    }
}

// MARK: - Requests

private extension FetchRequestBuilder where T: CategoryObject {
    static func by(id: UUID) -> FetchRequestBuilder<T> {
        Self()
            .setPredicate(
                StaticPredicateBuilder<T>()
                    .filter(by: \.id, value: id, comparison: .equal)
                    .build()
            )
            .setSortDescriptors([.init(keyPath: \T.title, ascending: true)])
    }
    
    static func by(weekDay: String) -> FetchRequestBuilder<T> {
        Self()
            .setPredicate(
                StaticPredicateBuilder<T>()
                    .subpredicate(by: \.trackers, subKeyPath: \.weekDays, subValue: weekDay, comparison: .contains)
                    .build()
            )
            .setSortDescriptors([.init(keyPath: \T.title, ascending: true)])
    }
}
