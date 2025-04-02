//
//  SectionCreationAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 02.04.2025.
//

import SwiftUI
import Foundation

final class SectionCreationAssembly {    
    @MainActor
    func assemble(sectionTitle: String?, completion: @escaping (String) -> Void) -> some View {
        let viewModel = SectionCreationViewModel(
            sectionTitle: sectionTitle,
            eventsHandler: { completion($0) }
        )
        
        let view = SectionCreationView(viewModel: viewModel)
        return view
    }
}
