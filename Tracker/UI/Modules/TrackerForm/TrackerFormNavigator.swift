//
//  TrackerFormNavigator.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.03.2025.
//

import Foundation
import SwiftUI

@MainActor
struct TrackerFormNavigator<Content: View, NavigationState: TrackerFormNavigationState> {
    private let sectionsListAssembly: SectionsListAssembly
    private let weekDaysSelectionAssembly: WeekDaysSelectionAssembly
    
    @ObservedObject private var navigationState: NavigationState
    
    private let content: Content
    
    init(
        sectionsListAssembly: SectionsListAssembly,
        weekDaysSelectionAssembly: WeekDaysSelectionAssembly,
        navigationState: NavigationState,
        content: () -> Content
    ) {
        self.sectionsListAssembly = sectionsListAssembly
        self.weekDaysSelectionAssembly = weekDaysSelectionAssembly
        self.navigationState = navigationState
        self.content = content()
    }
}

extension TrackerFormNavigator: View {
    var body: some View {
        content
            .sheet(item: $navigationState.route) { route in
                switch route {
                case .weekDay(let weekDays, let completion):
                    weekDaysSelectionAssembly.assemble(weekDays, onCompletion: completion)
                        .interactiveDismissDisabled()
                
                case .section(let id, let onCompletion):
                    sectionsListAssembly.assemble(id, onCompletion: onCompletion)
                        .interactiveDismissDisabled()
                }
            }
    }
}
