//
//  ModulesAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.08.2025.
//

import Foundation
import Swinject
import UIKit
import TrackerDomain
import HapticFeedback

final class ModulesAssembly: Assembly {
    func assemble(container: Container) {
        container.register(StatisticsAssembly.self) { r in
            StatisticsAssembly(
                statisticsManager: r.resolve(StatisticsManaging.self)!
            )
        }
        
        container.register(SectionCreationAssembly.self) { _ in
            SectionCreationAssembly()
        }
        
        container.register(SectionsListAssembly.self) { r in
            SectionsListAssembly(
                sectionRepository: r.resolve(SectionRepositoryProtocol.self)!,
                sectionCreationAssembly: r.resolve(SectionCreationAssembly.self)!
            )
        }
        
        container.register(TrackerFormAssembly.self) { r in
            TrackerFormAssembly(
                trackerManager: r.resolve(TrackerManaging.self)!,
                notificationManager: r.resolve((any AppNotificationManaging).self)!,
                sectionRepository: r.resolve(SectionRepositoryProtocol.self)!,
                sectionsListAssembly: r.resolve(SectionsListAssembly.self)!,
            )
        }
        
        container.register(TrackersAssembly.self) { r in
            TrackersAssembly(
                trackerManager: r.resolve(TrackerManaging.self)!,
                hapticManager: r.resolve(VibrationFeedbackManaging.self)!,
                notificationDeepLinkService: r.resolve(NotificationDeepLinkServiceProtocol.self)!,
                trackersViewModelsFactory: r.resolve(TrackersViewModelsFactory.self)!,
                trackerFormAssembly: r.resolve(TrackerFormAssembly.self)!
            )
        }
        
        container.register(TabBarAssembly.self) { r in
            TabBarAssembly(
                trackersAssembly: r.resolve(TrackersAssembly.self)!,
                statisticAssembly: r.resolve(StatisticsAssembly.self)!
            )
        }
        
        container.register(SplashViewAssembly.self) { r in
            SplashViewAssembly(
                tabBarAssembly: r.resolve(TabBarAssembly.self)!,
                authService: r.resolve(AuthServiceProtocol.self)!
            )
        }
    }
}
