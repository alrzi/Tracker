//
//  TrackerFormNavigationState.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.03.2025.
//

import Foundation
import TrackerDomain

@MainActor
protocol TrackerFormNavigationState: ObservableObject {
    var route: TrackerFormRoute? { get set }
}

enum TrackerFormRoute: Identifiable {
    case section(UUID?, onCompletion: (TrackerSection) -> Void)
    
    var id: ID {
        switch self {      
        case .section: .section
        }
    }
    
    enum ID {
        case section
    }
}
