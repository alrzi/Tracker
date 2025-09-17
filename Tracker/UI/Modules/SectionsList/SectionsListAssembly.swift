//
//  SectionsListAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 28.03.2025.
//

import SwiftUI
import Foundation
import TrackerDomain

final class SectionsListAssembly {
    typealias Context = UUID?
        
    private let sectionRepository: SectionRepositoryProtocol
    
    private let sectionCreationAssembly: SectionCreationAssembly
    
    init(
        sectionRepository: SectionRepositoryProtocol,
        sectionCreationAssembly: SectionCreationAssembly
    ) {
        self.sectionRepository = sectionRepository
        self.sectionCreationAssembly = sectionCreationAssembly
    }
    
    @MainActor
    func assemble(_ context: Context, onCompletion: @escaping (TrackerSection) -> Void) -> some View {
        let viewModel = SectionsListViewModel(
            sectionRepository: sectionRepository,
            sectionID: context,
            eventsHandler: { onCompletion($0) }
        )
        
        return SectionListNavigator(
            sectionCreationAssembly: sectionCreationAssembly,
            navigationState: viewModel
        ) {
            SectionsListView(viewModel: viewModel)
        }
    }
}
