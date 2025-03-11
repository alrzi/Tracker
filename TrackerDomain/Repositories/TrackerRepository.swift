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
    func createTracker(_ tracker: Tracker) async
    func getAllTrackers() async throws -> [Tracker]
    func getAllTrackers(isPinned: Bool) async throws -> [Tracker]
    func getTracker(by id: UUID) async throws -> Tracker
    func updateTracker(_ tracker: Tracker) async throws
    func deleteTracker(with id: UUID) async throws
    func addPrepared(sections: [TrackerSection])
}
