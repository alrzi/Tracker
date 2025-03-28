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
    
    private let sectionRepository: CategoryRepositoryProtocol
    
    init(sectionRepository: CategoryRepositoryProtocol) {
        self.sectionRepository = sectionRepository
    }
    
    @MainActor
    func assemble(_ context: Context, onCompletion: @MainActor @escaping (sending TrackerSection) -> Void) -> some View {
        let viewModel = SectionsListViewModel(
            sectionRepository: sectionRepository,
            sectionID: context,
            eventsHandler: { onCompletion($0) }
        )
        
        let view = SectionsListView(viewModel: viewModel)
        
        return view
    }
}
