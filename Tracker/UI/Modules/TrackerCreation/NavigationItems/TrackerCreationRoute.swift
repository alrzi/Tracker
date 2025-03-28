//
//  TrackerCreationNavigationState.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.03.2025.
//

import Foundation
import TrackerDomain

@MainActor
protocol TrackerCreationNavigationState: ObservableObject {
    var route: TrackerCreationRoute? { get set }
}

enum TrackerCreationRoute: Identifiable {
    case weekDay(WeekDays, onCompletion: @MainActor (sending WeekDays) -> Void)
    case section(UUID?, onCompletion: @MainActor (sending TrackerSection) -> Void)
    
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
