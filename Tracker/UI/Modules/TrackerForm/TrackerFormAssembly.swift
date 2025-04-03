//
//  TrackerFormAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import SwiftUI
import Foundation
import TrackerDomain

final class TrackerFormAssembly {
    private let sectionRepository: CategoryRepositoryProtocol
    
    private let sectionsListAssembly: SectionsListAssembly
    private let weekDaysSelectionAssembly: WeekDaysSelectionAssembly
        
    init(
        sectionRepository: CategoryRepositoryProtocol,
        sectionsListAssembly: SectionsListAssembly,
        weekDaysSelectionAssembly: WeekDaysSelectionAssembly
    ) {
        self.sectionRepository = sectionRepository
        self.sectionsListAssembly = sectionsListAssembly
        self.weekDaysSelectionAssembly = weekDaysSelectionAssembly
    }
    
    @MainActor
    func assemble(_ context: Tracker?, onCompletion: @escaping (TrackerSection) -> Void) -> some View {
        let viewModel = TrackerFormViewModel(
            sectionRepository: sectionRepository,
            tracker: context,
            eventsHandler: {
                switch $0 {
                case .section(let section):
                    onCompletion(section)
                }
            }
        )
        
        return TrackerFormNavigator(
            sectionsListAssembly: sectionsListAssembly,
            weekDaysSelectionAssembly: weekDaysSelectionAssembly,
            navigationState: viewModel
        ) {
            TrackerFormView(viewModel: viewModel)
        }
    }
}
