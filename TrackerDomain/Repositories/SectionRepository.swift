//
//  SectionRepositoryProtocol.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Foundation

public protocol SectionRepositoryProtocol: Sendable {
    // Create
    func createSection(_ section: TrackerSection) async throws
    func createSections(_ sections: [TrackerSection]) async throws
    
    // Read
    func getSections(fetchLimit: Int, fetchOffset: Int) async throws -> [TrackerSection]
    func getSections(params: RequestParameters) async throws -> [TrackerSection]
    func getSections(params: RequestParameters, isCompleted: Bool) async throws -> [TrackerSection]
    func getSection(by id: UUID) async throws -> TrackerSection
    
    // Update
    func updateSection(_ section: TrackerSection) async throws
    
    // Delete
    func deleteSection(with id: UUID) async throws
    func deleteAll() async throws
}
