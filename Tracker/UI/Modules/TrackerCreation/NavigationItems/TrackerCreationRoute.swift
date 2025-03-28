//
//  TrackerCreationNavigationState.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.03.2025.
//

import Foundation

@MainActor
protocol TrackerCreationNavigationState: ObservableObject {
    var route: TrackerCreationRoute? { get set }
}

enum TrackerCreationRoute: Identifiable {
    case weekDay(String, onCompletion: @MainActor @Sendable (String) -> Void)
    case section(String, onCompletion: @MainActor @Sendable (String) -> Void)
    
    var id: ID {
        switch self {
        case .weekDay: .weekDay
        case .section: .section
        }
    }
    
    enum ID {
        case weekDay
        case section
    }
}
