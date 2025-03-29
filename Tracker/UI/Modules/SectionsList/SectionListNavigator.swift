//
//  SectionListNavigator.swift
//  Tracker
//
//  Created by Александр Зиновьев on 29.03.2025.
//

import Foundation
import SwiftUI

struct SectionListNavigator<Content: View, NavigationState: SectionListNavigationState> {
    @ObservedObject private var navigationState: NavigationState
    
    private let content: Content
    
    init(
        navigationState: NavigationState,
        content: () -> Content
    ) {
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
                    Text("SADSAD")
                }
            }
    }
}
