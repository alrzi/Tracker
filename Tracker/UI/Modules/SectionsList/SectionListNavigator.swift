//
//  SectionListNavigator.swift
//  Tracker
//
//  Created by Александр Зиновьев on 29.03.2025.
//

import Foundation
import SwiftUI

@MainActor
struct SectionListNavigator<Content: View, NavigationState: SectionListNavigationState> {
    private let sectionCreationAssembly: SectionCreationAssembly
    
    @ObservedObject private var navigationState: NavigationState
    
    private let content: Content
    
    init(
        sectionCreationAssembly: SectionCreationAssembly,
        navigationState: NavigationState,
        content: () -> Content
    ) {
        self.sectionCreationAssembly = sectionCreationAssembly
        self.navigationState = navigationState
        self.content = content()
    }
}

extension SectionListNavigator: View {
    var body: some View {
        content
            .sheet(item: $navigationState.route) { route in
                switch route {
                case .createSection(let completion):
                    sectionCreationAssembly.assemble(section: nil, completion: completion)
                    
                case .updateSection(let section, let completion):
                    sectionCreationAssembly.assemble(section: section, completion: completion)
                }
            }
    }
}
