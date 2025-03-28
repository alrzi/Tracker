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
    private let sectionsListAssembly: SectionsListAssembly
    private let weekDaysSelectionAssembly: WeekDaysSelectionAssembly
        
    init(
        sectionsListAssembly: SectionsListAssembly,
        weekDaysSelectionAssembly: WeekDaysSelectionAssembly
    ) {
        self.sectionsListAssembly = sectionsListAssembly
        self.weekDaysSelectionAssembly = weekDaysSelectionAssembly
    }
    
    @MainActor
    func assemble(_ context: Tracker?, onCompletion: @MainActor @escaping (sending TrackerSection) -> Void) -> some View {
        let viewModel = TrackerCreationViewModel(
            tracker: context,
            eventsHandler: {
                switch $0 {
                case .section(let section):
                    onCompletion(section)
                }
            }
        )
        
        return TrackerCreationNavigator(
            sectionsListAssembly: sectionsListAssembly,
            weekDaysSelectionAssembly: weekDaysSelectionAssembly,
            navigationState: viewModel
        ) {
            TrackerCreationView(viewModel: viewModel)
        }
    }
}
