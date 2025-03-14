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
    
    func createSection(_ sections: TrackerSection) async {
        let object = await persistencyService.createObject(CategoryObject.self)
        object.copy(from: sections)
        
        await persistencyService.saveContext()
    }
    
    func createSections(_ sections: [TrackerSection]) async {
        for section in sections {
            let sectionObject = await persistencyService.createObject(CategoryObject.self)
            sectionObject.copy(from: section)
            
            for tracker in section.trackers {
                let trackerObject = await persistencyService.createObject(TrackerObject.self)
                trackerObject.copy(from: tracker)
                
                sectionObject.addToTrackers(trackerObject)
            }
        }
        
        await persistencyService.saveContext()
    }
        
    // MARK: - Read
    
    func getAllSections(weekDay: String) async throws -> [TrackerSection] {
        let request = FetchRequestBuilder<CategoryObject>.by(weekDay: weekDay).build()
        
        let objects = try await persistencyService.fetchObjects(with: request)
        let categories = objects.map(TrackerSection.init)
        return categories
    }
    
    func getCategory(by id: UUID) async throws -> TrackerSection {
        let request = FetchRequestBuilder<CategoryObject>.by(id: id).build()
        
        guard let object = try await persistencyService.fetchObject(with: request) else {
            throw CategoryRepositoryError.noTrackerForId
        }
        
        return .init(id: object.id, title: object.title, trackers: [])
    }
    
    // MARK: - Update
    
    func updateCategory(_ category: TrackerSection) async throws {
        let request = FetchRequestBuilder<CategoryObject>.by(id: category.id).build()
        
        guard let object = try await persistencyService.fetchObject(with: request) else {
            throw CategoryRepositoryError.noTrackerForId
        }
        
        object.copy(from: category)
        
        await persistencyService.saveContext()
    }
    
    // MARK: - Delete
    
    func deleteCategory(with id: UUID) async throws {
        let request = FetchRequestBuilder<CategoryObject>.by(id: id).build()
        
        guard let object = try await persistencyService.fetchObject(with: request) else {
            throw CategoryRepositoryError.noTrackerForId
        }
        
        await persistencyService.removeObject(object)
        
        await persistencyService.saveContext()
    }
    
    func deleteAll() async throws {
        try await persistencyService.deleteAllObjects(CategoryObject.self)
        
        await persistencyService.saveContext()
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

