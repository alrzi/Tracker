//
//  TrackerDomainContainer.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 11.03.2025.
//

import Foundation
import Swinject

public final class TrackerDomainAssembly: Assembly {
    public init() { }
    
    public func assemble(container: Container) {
        container.register(TrackerManaging.self) { r in
            TrackerManager(
                trackerRepository: r.resolve(TrackerRepositoryProtocol.self)!,
                recordRepository: r.resolve(RecordRepositoryProtocol.self)!,
                sectionRepository: r.resolve(SectionRepositoryProtocol.self)!
            )
        }
        
        container.register(StatisticsManaging.self) { r in
            StatisticsManager(
                trackerRepository: r.resolve(TrackerRepositoryProtocol.self)!,
                recordRepository: r.resolve(RecordRepositoryProtocol.self)!
            )
        }

        container.register(GenerateStatisticsInsightUseCaseProtocol.self) { r in
            GenerateStatisticsInsightUseCase(
                historyProvider: r.resolve(StatisticsInsightHistoryProviding.self)!,
                generator: r.resolve(StatisticsInsightGenerating.self)!
            )
        }

        container.register(ApplyStatisticsInsightUseCaseProtocol.self) { r in
            ApplyStatisticsInsightUseCase(
                trackerRepository: r.resolve(TrackerRepositoryProtocol.self)!
            )
        }
        
        container.register(AuthServiceProtocol.self) { r in
            AuthService(
                authDataStorage: r.resolve(AuthDataStorage.self)!
            )
        }
    }
}
