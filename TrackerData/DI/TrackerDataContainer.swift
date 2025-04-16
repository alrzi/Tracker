//
//  TrackerDataContainer.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 11.03.2025.
//

import Foundation
import TrackerDomain
internal import DataStorage

public enum TrackerDataContainer {
    static let persistentContainerProvider = PersistentContainerProvider(modelName: "Tracker")
    
    static let dataStorage = DataStorage(
        jsonDecoder: JSONDecoder(),
        jsonEncoder: JSONEncoder(),
        userDefaults: .standard,
        sharedUserDefaults: UserDefaults(suiteName: "shared") ?? .standard
    )
    
    static var persistencyService: PersistencyService {
        PersistencyService(provider: persistentContainerProvider)
    }
    
    public static var authDataStorage: AuthDataStorage {
        dataStorage
    }
    
    public static var trackerRepository: TrackerRepositoryProtocol {
        TrackerRepository(
            persistencyService: persistencyService
        )
    }
    
    public static var sectionRepository: SectionRepositoryProtocol {
        SectionRepository(
            persistencyService: persistencyService
        )
    }
    
    public static var recordRepository: RecordRepositoryProtocol {
        RecordRepository(
            persistencyService: persistencyService
        )
    }
}
