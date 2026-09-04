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
    }
}
