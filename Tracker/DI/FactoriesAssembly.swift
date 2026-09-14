//
//  FactoriesAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.08.2025.
//

import Foundation
import Swinject
import TrackerDomain
import HapticFeedback

final class FactoriesAssembly: Assembly {
    func assemble(container: Container) {
        container.register(TrackersViewModelsFactory.self) { r in
            TrackersViewModelsFactory(
                trackerManager: r.resolve(TrackerManaging.self)!,
                trackerRepository: r.resolve(TrackerRepositoryProtocol.self)!,
                recordRepository: r.resolve(RecordRepositoryProtocol.self)!,
                hapticManager: r.resolve(VibrationFeedbackManaging.self)!
            )
        }

        container.register(StatisticsInsightViewModelFactory.self) { r in
            StatisticsInsightViewModelFactory(
                generateUseCase: r.resolve(GenerateStatisticsInsightUseCaseProtocol.self)!,
                applyUseCase: r.resolve(ApplyStatisticsInsightUseCaseProtocol.self)!
            )
        }

        container.register(TrackerFormFactory.self) { r in
            TrackerFormFactory(
                trackerManager: r.resolve(TrackerManaging.self)!,
                notificationManager: r.resolve((any AppNotificationManaging).self)!,
                sectionRepository: r.resolve(SectionRepositoryProtocol.self)!
            )
        }

        container.register(SectionsListFactory.self) { r in
            SectionsListFactory(sectionRepository: r.resolve(SectionRepositoryProtocol.self)!)
        }

        container.register(SectionCreationFactory.self) { r in
            SectionCreationFactory(
                sectionRepository: r.resolve(SectionRepositoryProtocol.self)!
            )
        }

        container.register(TrackersScreenFactory.self) { r in
            TrackersScreenFactory(
                trackerManager: r.resolve(TrackerManaging.self)!,
                hapticManager: r.resolve(VibrationFeedbackManaging.self)!,
                notificationDeepLinkService: r.resolve(NotificationDeepLinkServiceProtocol.self)!,
                viewModelsFactory: r.resolve(TrackersViewModelsFactory.self)!
            )
        }

        container.register(StatisticsScreenFactory.self) { r in
            StatisticsScreenFactory(
                statisticsManager: r.resolve(StatisticsManaging.self)!,
                insightViewModelFactory: r.resolve(StatisticsInsightViewModelFactory.self)!
            )
        }
    }
}
