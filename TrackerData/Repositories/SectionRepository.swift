//
//  SectionRepository.swift
//  Tracker
//
//  Created by Александр Зиновьев on 20.07.2024.
//

import Foundation
import TrackerDomain

private enum SectionRepositoryError: Error {
    case noSectionForId
}

final class SectionRepository: SectionRepositoryProtocol {
    private let persistencyService: PersistencyService
    
    init(persistencyService: PersistencyService) {
        self.persistencyService = persistencyService
    }
    
    // MARK: - Create
    
    func createSection(_ section: TrackerSection) async throws {
        try await persistencyService.createObject(CategoryObject.self, from: section)
    }
    
    func createSections(_ sections: [TrackerSection]) async throws {
        for section in sections {
            try await persistencyService.createObjectAndAddToEntity(
                TrackerObject.self,
                from: section.trackers,
                CategoryObject.self,
                entityToAddTo: section
            )
        }
    }
    
    // MARK: - Read
    
    func getSections(fetchLimit: Int, fetchOffset: Int) async throws -> [TrackerSection] {
        let request = FetchRequestBuilder<CategoryObject>()
            .setSortDescriptors([.init(keyPath: \.title)])
            .setFetchLimit(fetchLimit)
            .setFetchOffset(fetchOffset)
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getSections(params: RequestParameters) async throws -> [TrackerSection] {
        let request = FetchRequestBuilder<CategoryObject>()
            .setPredicates(
                [
                    SubQuery(key: \.trackers, subKey: \.weekDays, that: .contains(params.weekDay.toNumberString())),
                ]
                + (!params.query.isEmpty ? [SubQuery(key: \.trackers, subKey: \.name, that: .contains(params.query))] : [])
            )
            .setSortDescriptors([.init(keyPath: \.title)])
            .setFetchLimit(params.fetchLimit)
            .setFetchOffset(params.fetchOffset)
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getSections(params: RequestParameters, isCompleted: Bool) async throws -> [TrackerSection] {
        let interval = params.currentDate.fullDayInterval()
        
        let request = FetchRequestBuilder<CategoryObject>()
            .setPredicates(
                [
                    SubQuery(key: \.trackers, subKey: \.weekDays, that: .contains(params.weekDay.toNumberString())),
                    SubSubQuery(key: \.trackers, subKey: \.trackerRecord, terKey: \.date, that: .between(interval.start, interval.end), isMore: isCompleted)
                ]
                + (!params.query.isEmpty ? [SubQuery(key: \.trackers, subKey: \.name, that: .contains(params.query))] : [])
            )
            .setSortDescriptors([.init(keyPath: \.title)])
            .setFetchLimit(params.fetchLimit)
            .setFetchOffset(params.fetchOffset)
            .build()
        
        return try await persistencyService.fetchObjects(with: request)
    }
    
    func getSection(by id: UUID) async throws -> TrackerSection {
        let request = FetchRequestBuilder<CategoryObject>()
            .setPredicates([Query(key: \.id, that: .equal(to: id))])
            .build()
        
        guard let section: TrackerSection = try await persistencyService.fetchObject(with: request) else {
            throw SectionRepositoryError.noSectionForId
        }
        
        return section
    }
    
    // MARK: - Update
    
    func updateSection(_ section: TrackerSection) async throws {
        let request = FetchRequestBuilder<CategoryObject>()
            .setPredicates([Query(key: \.id, that: .equal(to: section.id))])
            .build()
        
        try await persistencyService.updateObject(for: request, with: section)
    }
    
    // MARK: - Delete
    
    func deleteSection(with id: UUID) async throws {
        let request = FetchRequestBuilder<CategoryObject>()
            .setPredicates([Query(key: \.id, that: .equal(to: id))])
            .build()
        
        try await persistencyService.removeObject(for: request)
    }
    
    func deleteAll() async throws {
        try await persistencyService.deleteAllObjects(CategoryObject.self)
    }
}
