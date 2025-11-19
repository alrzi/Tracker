//
//  TrackerDataAssembly.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 11.03.2025.
//

import Foundation
import Swinject
internal import DataStorage
import TrackerDomain

public final class TrackerDataAssembly: Assembly {
    public init() { }
    
    public func assemble(container: Container) {
        container.register(PersistentContainerProviding.self) { _ in
            PersistentContainerProvider(modelName: "Tracker")
        }
        .inObjectScope(.container)
        
        container.register(PersistencyService.self) { r in
            PersistencyService(
                provider: r.resolve(PersistentContainerProviding.self)!
            )
        }
        
        container.register(DataStorage<DataStorageType>.self) { _ in
            DataStorage(
                jsonDecoder: JSONDecoder(),
                jsonEncoder: JSONEncoder(),
                userDefaultsProvider: {
                    switch $0 {
                    case .base: .standard
                    }
                }
            )
        }
        .inObjectScope(.container)
        .implements((any DataStorageProtocol).self)
        .implements(AuthDataStorage.self)
        
        container.register(AnalyticsProtocol.self) { _ in
            YandexMetricaAnaliticsTracker()
        }
        .inObjectScope(.container)
        
        container.register(TrackerRepositoryProtocol.self) { r in
            TrackerRepository(
                persistencyService: r.resolve(PersistencyService.self)!
            )
        }
        .inObjectScope(.container)
        
        container.register(SectionRepositoryProtocol.self) { r in
            SectionRepository(
                persistencyService: r.resolve(PersistencyService.self)!
            )
        }
        .inObjectScope(.container)
        
        container.register(RecordRepositoryProtocol.self) { r in
            RecordRepository(
                persistencyService: r.resolve(PersistencyService.self)!
            )
        }
        .inObjectScope(.container)
    }
}
