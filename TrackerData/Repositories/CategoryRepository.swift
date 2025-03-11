//
//  CategoryRepository.swift
//  Tracker
//
//  Created by Александр Зиновьев on 20.07.2024.
//

import Foundation
import TrackerDomain
import CoreData.NSFetchRequest

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

extension CategoryRepository: CategoryRepositoryProtocol {
    func save() {
        
    }
    
    func getCategory(by id: UUID) throws -> TrackerSection {
        .init(title: "", trackers: [])
    }
    
    func getAllCategories() -> [TrackerSection] {
        let objects = persistencyService.fetchObjects(CategoryObject.self)
        let categories = objects.map(TrackerSection.init)
        return categories
    }
    
    func getCategory(by id: UUID) async throws -> TrackerSection {
        let fetchRequest = NSFetchRequest<CategoryObject>(entityName: CategoryObject.entityName)
        fetchRequest.predicate = predicateBuilder.buildPredicateCategoryId(id: id)
        
        guard let object = try await persistencyService.fetchObjects(with: fetchRequest).first else {
            throw CategoryRepositoryError.noTrackerForId
        }
        
        return .init(id: object.id, title: object.title, trackers: [])
    }
    
    func createCategory(_ category: TrackerSection) {
        let object = persistencyService.createObject(CategoryObject.self)
        object.copy(from: category)
        
        persistencyService.saveContext()
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
