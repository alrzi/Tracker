//
//  RecordRepositoryProtocol.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Foundation

public protocol RecordRepositoryProtocol: Sendable {
    // Read
    func fetchRecords() async throws -> [TrackerRecord]
    func fetchRecords(for sectionId: UUID, for date: Date, weekDay: WeekDay, query: String, isPinned: Bool) async throws -> [TrackerRecord]
    func fetchRecords(for date: Date, weekDay: WeekDay, query: String, isPinned: Bool) async throws -> [TrackerRecord]
    func isCompletedFor(selectedDay date: Date, trackerWithId id: UUID) async throws -> Bool
    func getTrackedDaysFor(id: UUID) async throws -> Int
    func getCompletedTrackersCount() async throws -> Int
    
    // Create/Delete
    func createOrDeleteIfPresent(record: TrackerRecord) async throws
}
