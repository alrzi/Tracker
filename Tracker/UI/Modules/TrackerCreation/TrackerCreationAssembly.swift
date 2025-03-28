//
//  TrackerCreationAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import SwiftUI
import Foundation
import TrackerDomain

final class TrackerCreationAssembly {
    @MainActor
    func assemble(_ context: Tracker?, onCompletion: @MainActor @Sendable @escaping (TrackerSection) -> Void) -> some View {
        let viewModel = TrackerCreationViewModel(
            tracker: context,
            eventsHandler: {
                switch $0 {
                case .section(let section):
                    onCompletion(section)
                }
            }
        )
        
        return TrackerCreationNavigator(navigationState: viewModel) {
            TrackerCreationView(viewModel: viewModel)
        }
    }
}
