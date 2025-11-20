//
//  SectionRepository.swift
//  Tracker
//
//  Created by Александр Зиновьев on 20.07.2024.
//

import Foundation
import TrackerDomain

final class SectionRepository: SectionRepositoryProtocol {
    private let persistencyService: PersistencyService
    
    init(persistencyService: PersistencyService) {
        self.persistencyService = persistencyService
    }
    
    // MARK: - Create
    
    func createSection(_ section: TrackerSection) async throws {
        try await persistencyService.performCreate {
            $0.make(CategoryObject.self).copy(from: section)
        }
    }
    
    func createSections(_ sections: [TrackerSection]) async throws {
        for section in sections {
            try await persistencyService.performCreate {
                let categoryObject = $0.make(CategoryObject.self)
                categoryObject.copy(from: section)

                for tracker in section.trackers {
                    let trackerObject = $0.make(TrackerObject.self)
                    trackerObject.copy(from: tracker)
                    categoryObject.addToTrackers(trackerObject)
                }
            }
        }
    }
    
    // MARK: - Read
    
    func getSections(fetchLimit: Int, fetchOffset: Int) async throws -> [TrackerSection] {
        try await persistencyService.perform {
            try $0.fetchAll(
                FetchRequestBuilder<CategoryObject>()
                    .setSortDescriptors([.init(keyPath: \.title)])
                    .setFetchLimit(fetchLimit)
                    .setFetchOffset(fetchOffset)
                    .build()
            )
        }
    }
    
    func getSections(params: RequestParameters) async throws -> [TrackerSection] {
        try await persistencyService.perform {
            try $0.fetchAll(
                FetchRequestBuilder<CategoryObject>()
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
            )
        }
    }
    
    func getSections(params: RequestParameters, isCompleted: Bool) async throws -> [TrackerSection] {
        try await persistencyService.perform {
            let interval = params.currentDate.fullDayInterval()

            return try $0.fetchAll(
                FetchRequestBuilder<CategoryObject>()
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
            )
        }
    }
    
    func getSection(by id: UUID) async throws -> TrackerSection {
        try await persistencyService.perform {
            try $0.fetchOne(
                FetchRequestBuilder<CategoryObject>()
                    .setPredicates([Query(key: \.id, that: .equal(to: id))])
                    .build()
            )
        }
    }
    
    // MARK: - Update
    
    func updateSection(_ section: TrackerSection) async throws {
        try await persistencyService.performUpdateOrCreate {
            let categoryObject: CategoryObject = try $0.fetchOneRaw(
                FetchRequestBuilder<CategoryObject>()
                    .setPredicates([Query(key: \.id, that: .equal(to: section.id))])
                    .build()
            )

            categoryObject.copy(from: section)
        }
    }
    
    // MARK: - Delete
    
    func deleteSection(with id: UUID) async throws {
        try await persistencyService.performRemove {
            $0.delete(
                try $0.fetchOneRaw(
                    FetchRequestBuilder<CategoryObject>()
                        .setPredicates([Query(key: \.id, that: .equal(to: id))])
                        .build()
                )
            )
        }
    }
    
    func deleteAll() async throws {
        try await persistencyService.deleteAllObjects(CategoryObject.self)
    }
}
