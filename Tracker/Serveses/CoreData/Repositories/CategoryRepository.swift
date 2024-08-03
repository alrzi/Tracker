//
//  CategoryRepository.swift
//  Tracker
//
//  Created by Александр Зиновьев on 20.07.2024.
//

import Foundation
import CoreData

enum CategoryRepositoryError: Error {
    case noTrackerForId
}

protocol CategoryRepositoryProtocol {
    func createCategory(_ category: TrackerSection)
    func getAllCategories() -> [TrackerSection]
    func getCategory(by id: UUID) throws -> TrackerSection
    func updateCategory(_ category: TrackerSection) throws
    func deleteCategory(with id: UUID) throws
    func save()
}

final class CategoryRepository {
    private let persistencyService: PersistencyService
    private let predicateBuilder: PredicateBuilder
    
    init(
        persistencyService: PersistencyService,
        predicateBuilder: PredicateBuilder
    ) {
        self.persistencyService = persistencyService
        self.predicateBuilder = predicateBuilder
    }
}

extension CategoryRepository {
    func createCategory(_ category: TrackerSection) {
        let object = persistencyService.createObject(CategoryObject.self)
        object.copy(from: category)
        
        persistencyService.saveContext()
    }
    
    func getAllCategories() -> [TrackerSection] {
        let objects = persistencyService.fetchObjects(CategoryObject.self)
        let categories = objects.map(TrackerSection.init)
        return categories
    }
    
    func getCategory(by id: UUID) throws -> TrackerSection {
        guard let object = persistencyService.fetchObject(CategoryObject.self, by: \.id, value: id)?.first else {
            throw CategoryRepositoryError.noTrackerForId
        }                
        
        return .init(object: object)
    }
    
    func updateCategory(_ category: TrackerSection) throws {
        guard let object = persistencyService.fetchObject(CategoryObject.self, by: \.id, value: category.id)?.first else {
            throw CategoryRepositoryError.noTrackerForId
        }
        
        object.copy(from: category)
        
        persistencyService.saveContext()
    }
    
    func deleteCategory(with id: UUID) throws {
        guard let object = persistencyService.fetchObject(CategoryObject.self, by: \.id, value: id)?.first else {
            throw CategoryRepositoryError.noTrackerForId
        }
        
        persistencyService.removeObject(object)
        
        persistencyService.saveContext()
    }
    
    func deleteAll() {
        persistencyService.deleteAllObjects(CategoryObject.self)
        
        persistencyService.saveContext()
    }
}
