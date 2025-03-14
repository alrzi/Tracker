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

public protocol CategoryRepositoryProtocol: Sendable {
    // Create
    func createSection(_ section: TrackerSection) async
    func createSections(_ sections: [TrackerSection]) async
    
    // Read
    func getAllSections(weekDay: String) async throws -> [TrackerSection]
    func getCategory(by id: UUID) async throws -> TrackerSection
    
    // Update
    func updateCategory(_ category: TrackerSection) async throws
    
    // Delete
    func deleteCategory(with id: UUID) async throws
    func deleteAll() async throws
}
