//
//  CategoryRepositoryProtocol.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Foundation

public enum CategoryRepositoryError: Error {
    case noTrackerForId
}

public protocol CategoryRepositoryProtocol {
    func getAllCategories() -> [TrackerSection]
    func getCategory(by id: UUID) throws -> TrackerSection
    
    func createCategory(_ category: TrackerSection)
    func updateCategory(_ category: TrackerSection) throws
    func deleteCategory(with id: UUID) throws
}
