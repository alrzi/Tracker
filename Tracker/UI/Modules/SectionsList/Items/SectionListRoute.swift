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
    case createSection(onCompletion: (TrackerSection) -> Void)
    case updateSection(_ section: TrackerSection, onCompletion: (TrackerSection) -> Void)
    
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
