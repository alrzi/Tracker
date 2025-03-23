//
//  TrackerCreationSwiftUIAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import SwiftUI
import Foundation
import Presentation

final class TrackerCreationSwiftUIAssembly: ViewControllerAssembly {
    typealias Context = LifecycleManagingContext<(), Never, ()>
    
    @MainActor
    func assemble(_ context: Context) -> UIViewController {
        let viewModel = TrackerCreationSwiftUIViewModel()
        let view = TrackerCreationSwiftUIView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        return viewController
    }
}
