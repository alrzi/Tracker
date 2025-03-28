//
//  TrackerRepository.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Foundation

public enum TrackerRepositoryError: Error {
    case noTrackerForId
    case noCategoryForId
}

public protocol TrackerRepositoryProtocol: Sendable {
    // Create
    func createTracker(_ tracker: Tracker) async throws
    func addSection(withId id: UUID, toTracker tracker: Tracker) async throws
    
    // Read    
    func getTrackers(for category: UUID, isPinned: Bool, weekDay: WeekDay, query: String) async throws -> [Tracker]
    func getTrackers(for category: UUID, isPinned: Bool, weekDay: WeekDay, query: String, date: Date) async throws -> [Tracker]
    func getTrackers(isPinned: Bool, weekDay: WeekDay, query: String, date: Date) async throws -> [Tracker]
    func getTrackers(id: UUID) async throws -> [Tracker]
    func getTrackers(isPinned: Bool, weekDay: WeekDay, query: String) async throws -> [Tracker]
    func isPinnedTrackersExist() async throws -> Bool
    
    // Update
    func updateTracker(_ tracker: Tracker) async throws
    
    // Delete
    func deleteTracker(with id: UUID) async throws
}
