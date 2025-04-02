//
//  SectionCreationAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 02.04.2025.
//

import SwiftUI
import Foundation
import TrackerDomain

final class SectionCreationAssembly {    
    @MainActor
    func assemble(section: TrackerSection?, completion: @escaping (TrackerSection) -> Void) -> some View {
        let viewModel = SectionCreationViewModel(
            section: section,
            eventsHandler: { completion($0) }
        )
        
        let view = SectionCreationView(viewModel: viewModel)
        return view
    }
}
