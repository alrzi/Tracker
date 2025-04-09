//
//  TrackerDomainContainer.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 11.03.2025.
//

import Foundation

public enum TrackerDomainContainer {
    public static func trackerManager(
        trackerRepository: some TrackerRepositoryProtocol,
        recordRepository: some RecordRepositoryProtocol,
        sectionRepository: some SectionRepositoryProtocol
    ) -> some TrackerManaging {
        TrackerManager(
            trackerRepository: trackerRepository,
            recordRepository: recordRepository,
            sectionRepository: sectionRepository
        )
    }
    
    public static func statisticManager(
        trackerRepository: some TrackerRepositoryProtocol,
        recordRepository: some RecordRepositoryProtocol
    ) -> some StatisticsManaging {
        StatisticsManager(trackerRepository: trackerRepository, recordRepository: recordRepository)
    }
    
    public static func authService(dataStorage: some AuthDataStorage) -> some AuthServiceProtocol {
        AuthService(authDataStorage: dataStorage)
    }
}
