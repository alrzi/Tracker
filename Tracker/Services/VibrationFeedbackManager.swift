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
    @MainActor
    private let generator: UINotificationFeedbackGenerator
    
    @MainActor
    private let selectionGenerator: UISelectionFeedbackGenerator
    
    init(
        generator: UINotificationFeedbackGenerator,
        selectionGenerator: UISelectionFeedbackGenerator
    ) {
        self.generator = generator
        self.selectionGenerator = selectionGenerator
    }
    
    func makeVibration(for type: NotificationFeedbackType) {
        if case .selection = type {
            selectionGenerator.prepare()
            selectionGenerator.selectionChanged()
        }
        else {
            guard let feedbackType = type.feedbackType else {
                return
            }
            
            generator.prepare()
            generator.notificationOccurred(feedbackType)
        }
    }
}

enum NotificationFeedbackType {
    case error
    case success
    case warning
    case selection
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
