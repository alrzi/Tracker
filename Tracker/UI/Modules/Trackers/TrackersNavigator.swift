//
//  TrackersNavigator.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.03.2025.
//

import Foundation
import SwiftUI

struct TrackersNavigator<Content: View, NavigationState: TrackersNavigationState> {
    private let trackerCreationSwiftUIAssembly: TrackerCreationAssembly
    
    @ObservedObject private var navigationState: NavigationState
    
    private let content: Content
    
    init(
        trackerCreationSwiftUIAssembly: TrackerCreationAssembly,
        navigationState: NavigationState,
        content: () -> Content
    ) {
        self.trackerCreationSwiftUIAssembly = trackerCreationSwiftUIAssembly
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
                    trackerCreationSwiftUIAssembly.assemble(tracker, onCompletion: completion)
                        .interactiveDismissDisabled()
                    
                case .create(let completion):
                    trackerCreationSwiftUIAssembly.assemble(nil, onCompletion: completion)
                        .interactiveDismissDisabled()
                }
            }
    }
}
