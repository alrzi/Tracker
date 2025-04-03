//
//  TrackersNavigator.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.03.2025.
//

import Foundation
import SwiftUI

@MainActor
struct TrackersNavigator<Content: View, NavigationState: TrackersNavigationState> {
    private let trackerCreationAssembly: TrackerCreationAssembly
    
    @ObservedObject private var navigationState: NavigationState
    
    private let content: Content
    
    init(
        trackerCreationAssembly: TrackerCreationAssembly,
        navigationState: NavigationState,
        content: () -> Content
    ) {
        self.trackerCreationAssembly = trackerCreationAssembly
        self.navigationState = navigationState
        self.content = content()
    }
}

extension TrackersNavigator: View {
    var body: some View {
        content
            .sheet(item: $navigationState.route) { route in
                switch route {
                case .update(let tracker, let completion):
                    trackerCreationAssembly.assemble(tracker, onCompletion: completion)
                        .interactiveDismissDisabled()
                    
                case .create(let completion):
                    trackerCreationAssembly.assemble(nil, onCompletion: completion)
                        .interactiveDismissDisabled()
                }
            }
    }
}
