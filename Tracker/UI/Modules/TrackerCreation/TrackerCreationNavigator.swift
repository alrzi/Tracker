//
//  TrackerCreationNavigator.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.03.2025.
//

import Foundation
import SwiftUI

struct TrackerCreationNavigator<Content: View, NavigationState: TrackerCreationNavigationState> {
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

extension TrackerCreationNavigator: View {
    var body: some View {
        content
            .sheet(item: $navigationState.route) { route in
                switch route {
                case .weekDay:
                    WeekDaysSelectionAssembly().assemble("")                       
                
                case .section:
                    Text("DS")
                }
            }
    }
}
