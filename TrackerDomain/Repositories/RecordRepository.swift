//
//  RecordRepositoryProtocol.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Foundation

public protocol RecordRepositoryProtocol: Sendable {
    // Create/Delete
    func createOrDeleteIfPresent(for trackerId: UUID, date: Date) async throws
    
    // Read
    var numberOfCompletedTrackers: Int { get async throws }
    
    func isCompletedFor(selectedDay date: Date, trackerWithId id: UUID) async throws -> Bool
    func getTrackedDaysFor(id: UUID) async throws -> Int        
}
