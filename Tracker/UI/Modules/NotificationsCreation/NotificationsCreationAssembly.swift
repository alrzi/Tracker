//
//  NotificationsCreationAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.08.2025.
//

import SwiftUI
import Foundation

final class NotificationsCreationAssembly {
    @MainActor
    func assemble(completion: @escaping () -> Void) -> some View {
        let viewModel = NotificationsCreationViewModel()
        let view = NotificationsCreationView(viewModel: viewModel)
        
        return view
    }
}
