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
    static let persistencyService = PersistencyService()
    static let dataStorage = DataStorage(
        jsonDecoder: JSONDecoder(),
        jsonEncoder: JSONEncoder(),
        userDefaults: .standard,
        sharedUserDefaults: UserDefaults(suiteName: "shared") ?? .standard
    )
    
    public static var authDataStorage: AuthDataStorage {
        dataStorage
    }
    
    public static var analyticsTracker: AnalyticsTracking {
        YMMYandexMetricaAnaliticsTracker()
    }
    
    public static var trackerRepository: TrackerRepositoryProtocol {
        TrackerRepository(
            persistencyService: persistencyService
        )
    }
    
    public static var categoryRepository: CategoryRepositoryProtocol {
        CategoryRepository(
            persistencyService: persistencyService
        )
    }
    
    public static var recordRepository: RecordRepositoryProtocol {
        RecordRepository(
            persistencyService: persistencyService
        )
    }
}
