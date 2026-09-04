//
//  StatisticsManager.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 08.04.2025.
//

import Foundation
import Utils

public protocol StatisticsManaging: Sendable {
    func getCompletedTrackersCount() async throws -> Int
    func getMaxDaysWithoutBreakCount() async throws -> Int
    func getDaysCountWhenAllTrackersAreCompleted() async throws -> Int
    func getAverageCompletedTrackersPerDayCount() async throws -> Int
}

struct StatisticsManager: StatisticsManaging {
    private let trackerRepository: TrackerRepositoryProtocol
    private let recordRepository: RecordRepositoryProtocol
    
    init(
        trackerRepository: TrackerRepositoryProtocol,
        recordRepository: RecordRepositoryProtocol,
    ) {
        self.trackerRepository = trackerRepository
        self.recordRepository = recordRepository
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
        var daysWithoutBreak = 1
        var maxDaysWithoutBreak = 1
        
        for record in records.dropFirst() {
            guard record.date.component(.day) != previousRecord.date.component(.day) else {
                continue
            }

            if record.date.isNextDay(after: previousRecord.date) {
                daysWithoutBreak += 1
            }
            else {
                daysWithoutBreak = 1
            }
            
            maxDaysWithoutBreak = max(maxDaysWithoutBreak, daysWithoutBreak)
            
            previousRecord = record
        }
        
        return maxDaysWithoutBreak
    }
    
    func getDaysCountWhenAllTrackersAreCompleted() async throws -> Int {
        let records = try await recordRepository.fetchRecords()
        
        var trackersDict: [WeekDay: [Tracker]] = [:]
        
        for day in WeekDay.allCases {
            trackersDict[day] = try await trackerRepository.getTrackers(for: day)
        }
        
        let recordsByDate = Dictionary(grouping: records) { $0.date.startOfDay() }

        var completionCounts = 0
        
        for (date, recordsOnDate) in recordsByDate {
            let completedTrackers = Set(recordsOnDate.map { $0.id })
            
            let weekDate = WeekDay.getWeekDay(from: date)
            
            if let trackersForWeekDay = trackersDict[weekDate], trackersForWeekDay.count == completedTrackers.count {
                completionCounts += 1
            }
        }
        
        return completionCounts
    }
    
    func getAverageCompletedTrackersPerDayCount() async throws -> Int {
        let records = try await recordRepository.fetchRecords()
        
        let recordsByDate = Dictionary(grouping: records) { $0.date.startOfDay() }
        
        var averagePerDate = 0
        
        for (_, recordsOnDate) in recordsByDate {
            let completedTrackers = Set(recordsOnDate.map { $0.id })
            
            averagePerDate += completedTrackers.count
        }
        
        guard !recordsByDate.keys.isEmpty else {
            return .zero
        }
        
        return averagePerDate / recordsByDate.keys.count
    }
}
