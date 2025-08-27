//
//  VibrationFeedbackManager.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import UIKit
import AudioToolbox

protocol VibrationFeedbackManaging {
    @MainActor
    func makeVibration(for type: NotificationFeedbackType)
}

final class VibrationFeedbackManager: VibrationFeedbackManaging {
    private let generatorProvider: @Sendable @MainActor () -> UINotificationFeedbackGenerator
    private let selectionGenerator: @Sendable @MainActor () -> UISelectionFeedbackGenerator
    
    init(
        generatorProvider: @escaping @Sendable @MainActor () -> UINotificationFeedbackGenerator,
        selectionGenerator: @escaping @Sendable @MainActor () -> UISelectionFeedbackGenerator
    ) {
        self.generatorProvider = generatorProvider
        self.selectionGenerator = selectionGenerator
    }
    
    func makeVibration(for type: NotificationFeedbackType) {
        if case .selection = type {
            let selectionGenerator = selectionGenerator()
            
            selectionGenerator.prepare()
            selectionGenerator.selectionChanged()
        }
        else {
            guard let feedbackType = type.feedbackType else {
                return
            }
            
            let generator = generatorProvider()
            
            generator.prepare()
            generator.notificationOccurred(feedbackType)
        }
    }
}

private extension NotificationFeedbackType {
    var feedbackType: UINotificationFeedbackGenerator.FeedbackType? {
        switch self {
        case .success: return .success
        case .warning: return .warning
        case .error: return .error
        case .selection: return nil
        }
    }
}
