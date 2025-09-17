//
//  ServicesAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.08.2025.
//

import Foundation
import Swinject
import UIKit
import TrackerDomain

final class ServicesAssembly: Assembly {
    func assemble(container: Container) {
        container.register(VibrationFeedbackManaging.self) { _ in
            VibrationFeedbackManager(
                generatorProvider: { UINotificationFeedbackGenerator() },
                selectionGenerator: { UISelectionFeedbackGenerator() }
            )
        }
        
        container.register(NotificationDeepLinkServiceProtocol.self) { r in
            NotificationDeepLinkService(
                deepLinkService: r.resolve(DeepLinkServiceFactory.self)!.create()
            )
        }
        .inObjectScope(.container)
        
        container.register(DeepLinkServiceFactory.self) { _ in
            DeepLinkServiceFactory()
        }
        
        container.register(UNUserNotificationCenterDelegate.self) { r in
            NotificationCenterDelegate(
                notificationDeepLinkService: r.resolve(NotificationDeepLinkServiceProtocol.self)!
            )
        }
    }
}
