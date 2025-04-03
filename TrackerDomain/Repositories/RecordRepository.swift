//
//  RecordRepositoryProtocol.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Foundation

public protocol RecordRepositoryProtocol: Sendable {
    // Read
    var numberOfCompletedTrackers: Int { get async throws }
    
    // Create/Delete
    func createOrDeleteIfPresent(record: TrackerRecord) async throws
    
    func fetchRecords(for sectionId: UUID, for date: Date, weekDay: WeekDay, query: String, isPinned: Bool) async throws -> [TrackerRecord]
    func fetchRecords(for date: Date, weekDay: WeekDay, query: String, isPinned: Bool) async throws -> [TrackerRecord]
    func isCompletedFor(selectedDay date: Date, trackerWithId id: UUID) async throws -> Bool
    func getTrackedDaysFor(id: UUID) async throws -> Int        
}
