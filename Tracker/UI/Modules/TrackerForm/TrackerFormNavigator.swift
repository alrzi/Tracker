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
    private let content: Content
    
    @ObservedObject private var navigationState: NavigationState
    
    init(
        sectionsListAssembly: SectionsListAssembly,
        navigationState: NavigationState,
        content: () -> Content
    ) {
        self.sectionsListAssembly = sectionsListAssembly
        self.navigationState = navigationState
        self.content = content()
    }
}

extension TrackerFormNavigator: View {
    var body: some View {
        content
            .sheet(item: $navigationState.route) { route in
                switch route {                
                case .section(let id, let onCompletion):
                    sectionsListAssembly.assemble(
                        id,
                        onCompletion: onCompletion,
                        onClose: closeSectionsList
                    )
                        .interactiveDismissDisabled()
                }
            }
    }
}

private extension TrackerFormNavigator {
    func closeSectionsList() {
        navigationState.route = nil
    }
}
