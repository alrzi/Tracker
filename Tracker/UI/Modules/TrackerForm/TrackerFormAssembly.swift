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
    private let sectionRepository: SectionRepositoryProtocol
    
    private let sectionsListAssembly: SectionsListAssembly
    private let weekDaysSelectionAssembly: WeekDaysSelectionAssembly
        
    init(
        sectionRepository: SectionRepositoryProtocol,
        sectionsListAssembly: SectionsListAssembly,
        weekDaysSelectionAssembly: WeekDaysSelectionAssembly
    ) {
        self.sectionRepository = sectionRepository
        self.sectionsListAssembly = sectionsListAssembly
        self.weekDaysSelectionAssembly = weekDaysSelectionAssembly
    }
    
    @MainActor
    func assemble(_ mode: TrackerFormMode, onCompletion: @escaping (TrackerFormOutput) -> Void) -> some View {
        let viewModel = TrackerFormViewModel(
            sectionRepository: sectionRepository,
            mode: mode,
            eventsHandler: { onCompletion($0) }
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
