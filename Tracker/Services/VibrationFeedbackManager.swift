//
//  VibrationFeedbackManager.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import UIKit
import AudioToolbox

@MainActor
protocol VibrationFeedbackManaging {
    func makeVibration(for type: NotificationFeedbackType)
}

final class VibrationFeedbackManager: VibrationFeedbackManaging {
    private let generator: UINotificationFeedbackGenerator
    private let selectionGenerator: UISelectionFeedbackGenerator
    
    init() {
        generator = UINotificationFeedbackGenerator()
        selectionGenerator = UISelectionFeedbackGenerator()
    }
    
    func makeVibration(for type: NotificationFeedbackType) {
        if case .selection = type {
            makeSelectionVibration()
        }
        else {
            makeTapticEngineVibration(for: type)
        }
    }
    
    private func makeSelectionVibration() {
        selectionGenerator.prepare()
        selectionGenerator.selectionChanged()
    }
    
    private func makeTapticEngineVibration(for type: NotificationFeedbackType) {
        guard let feedbackType = type.feedbackType else {
            return
        }
        generator.prepare()
        generator.notificationOccurred(feedbackType)
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
