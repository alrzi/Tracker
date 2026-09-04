//
//  TrackerDataAssembly.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 11.03.2025.
//

import Foundation
import Swinject
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


        // MARK: - KeyValueStorage
        container.register(AuthDataStorage.self) { _ in UserDefaults.live }
    }
}
