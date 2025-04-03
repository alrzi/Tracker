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
    private let trackerFormAssembly: TrackerFormAssembly
    
    @ObservedObject private var navigationState: NavigationState
    
    private let content: Content
    
    init(
        trackerFormAssembly: TrackerFormAssembly,
        navigationState: NavigationState,
        content: () -> Content
    ) {
        self.trackerFormAssembly = trackerFormAssembly
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
                    trackerFormAssembly.assemble(.editTracker(tracker), onCompletion: completion)
                        .interactiveDismissDisabled()
                    
                case .create(let completion):
                    trackerFormAssembly.assemble(.createTracker, onCompletion: completion)
                        .interactiveDismissDisabled()
                }
            }
    }
}
