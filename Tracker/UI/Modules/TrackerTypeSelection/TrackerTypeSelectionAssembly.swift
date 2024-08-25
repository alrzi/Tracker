//
//  TrackerTypeSelectionAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import UIKit
import Presentation

final class TrackerTypeSelectionAssembly: ViewControllerAssembly {
    typealias Context = LifecycleManagingContext<TrackerKind, Never, ()>
    
    private let createTrackerAssembly: TrackerCreationAssembly
    
    init(createTrackerAssembly: TrackerCreationAssembly) {
        self.createTrackerAssembly = createTrackerAssembly
    }
    
    func assemble(_ context: Context) -> UIViewController {
        let viewModel = TrackerTypeSelectionViewModel(            
            resultObserver: context.resultObserver
        )
        
        let viewController = TrackerTypeSelectionViewController(viewModel: viewModel)
        
        return viewController
    }
}
