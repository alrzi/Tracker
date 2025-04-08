//
//  StatisticsManager.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 08.04.2025.
//

import Foundation

public protocol StatisticsManaging: Sendable {
    func getCompletedTrackersCount() async throws -> Int
    func getMaxDaysWithoutBreakCount() async throws -> Int
}

struct StatisticsManager: StatisticsManaging {
    private let trackerRepository: TrackerRepositoryProtocol
    private let recordRepository: RecordRepositoryProtocol
    private let calendar: Calendar
    
    init(
        trackerRepository: TrackerRepositoryProtocol,
        recordRepository: RecordRepositoryProtocol,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        self.trackerRepository = trackerRepository
        self.recordRepository = recordRepository
        self.calendar = calendar
    }
    
    func getCompletedTrackersCount() async throws -> Int {
        try await recordRepository.getCompletedTrackersCount()
    }
    
    func getMaxDaysWithoutBreakCount() async throws -> Int {
        let records = try await recordRepository.fetchRecords()
        
        guard let firstRecord = records.first else {
            return .zero
        }
        
        var previousRecord = firstRecord
        var daysWithoutBreak = 0
        var maxDaysWithoutBreak = 0
        
        for record in records.dropFirst() {
            if calendar.isDate(record.date, inSameDayAs: previousRecord.date.adjust(.day, offset: 1)) {
                daysWithoutBreak += 1
            }
            else {
                daysWithoutBreak = 0
            }
            
            maxDaysWithoutBreak = max(maxDaysWithoutBreak, daysWithoutBreak)
            
            previousRecord = record
        }
        
        return maxDaysWithoutBreak
    }
    
    func getDaysCountWhenAllTrackersAreCompleted() async throws -> Int {
        .zero
    }
}
