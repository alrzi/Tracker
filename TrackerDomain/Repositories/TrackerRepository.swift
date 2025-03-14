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
    func createTracker(_ tracker: Tracker) async
    func addSection(withId id: UUID, toTracker tracker: Tracker) async throws
    
    // Read
    func getAllTrackersForCategory(category: UUID, isPinned: Bool, weekDay: String) async throws -> [Tracker]
    func getAllTrackers() async throws -> [Tracker]
    func getAllTrackers(isPinned: Bool) async throws -> [Tracker]
    func getTracker(by id: UUID) async throws -> Tracker
    
    // Update
    func updateTracker(_ tracker: Tracker) async throws
    
    // Delete
    func deleteTracker(with id: UUID) async throws
}
