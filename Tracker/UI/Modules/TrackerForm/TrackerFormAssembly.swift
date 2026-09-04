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
    private let trackerManager: any TrackerManaging
    private let notificationManager: any AppNotificationManaging
    private let sectionRepository: SectionRepositoryProtocol

    private let sectionsListAssembly: SectionsListAssembly
        
    init(
        trackerManager: any TrackerManaging,
        notificationManager: some AppNotificationManaging,
        sectionRepository: SectionRepositoryProtocol,
        sectionsListAssembly: SectionsListAssembly,
    ) {
        self.trackerManager = trackerManager
        self.notificationManager = notificationManager
        self.sectionRepository = sectionRepository
        self.sectionsListAssembly = sectionsListAssembly
    }
    
    @MainActor
    func assemble(_ mode: TrackerFormMode, onCompletion: @escaping (TrackerFormOutput) -> Void) -> some View {
        let viewModel = TrackerFormViewModel(
            trackerManager: trackerManager,
            notificationManager: notificationManager,
            sectionRepository: sectionRepository,
            mode: mode,
            eventsHandler: { onCompletion($0) }
        )
        
        return TrackerFormNavigator(
            sectionsListAssembly: sectionsListAssembly,
            navigationState: viewModel
        ) {
            TrackerFormView(viewModel: viewModel)
        }
    }
}
