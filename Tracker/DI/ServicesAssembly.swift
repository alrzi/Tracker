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
    }
}
