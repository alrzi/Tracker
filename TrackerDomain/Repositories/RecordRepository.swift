//
//  RecordRepositoryProtocol.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Foundation

public protocol RecordRepositoryProtocol: Sendable {
    var numberOfCompletedTrackers: Int { get }
    
    func getTrackedDaysFor(id: UUID) -> Int
    func removeOrAddRecordOf(tracker: Tracker, forParticularDay date: Date)
}
