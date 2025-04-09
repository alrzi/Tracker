//
//  TrackerRepository.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Foundation

public protocol TrackerRepositoryProtocol: Sendable {
    // Create
    func createTracker(_ tracker: Tracker) async throws
    func createTrackerAndAddToSection(with id: UUID, tracker: Tracker) async throws
    
    // Read
    func getTrackers(for sectionID: UUID, isPinned: Bool, weekDay: WeekDay, query: String) async throws -> [Tracker]
    func getTrackers(for sectionID: UUID, isPinned: Bool, weekDay: WeekDay, query: String, date: Date) async throws -> [Tracker]
    
    func getTrackers(isPinned: Bool, weekDay: WeekDay, query: String) async throws -> [Tracker]
    func getTrackers(isPinned: Bool, weekDay: WeekDay, query: String, date: Date) async throws -> [Tracker]
    
    func getTrackers(for weekDay: WeekDay) async throws -> [Tracker]
    func getTrackers(id: UUID) async throws -> [Tracker]
    func getTrackers() async throws -> [Tracker]
    
    // Update
    func updateTracker(_ tracker: Tracker) async throws
    
    // Delete
    func deleteTracker(with id: UUID) async throws
}
