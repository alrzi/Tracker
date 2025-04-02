//
//  SectionListRoute.swift
//  Tracker
//
//  Created by Александр Зиновьев on 29.03.2025.
//

import Foundation
import TrackerDomain

@MainActor
protocol SectionListNavigationState: ObservableObject {
    var route: SectionListRoute? { get set }
}

enum SectionListRoute: Identifiable {
    case createSection(onCompletion: (String) -> Void)
    case updateSection(title: String, onCompletion: (String) -> Void)
    
    var id: ID {
        switch self {
        case .createSection: .createSection
        case .updateSection: .updateSection
        }
    }
    
    enum ID {
        case createSection
        case updateSection
    }
}
