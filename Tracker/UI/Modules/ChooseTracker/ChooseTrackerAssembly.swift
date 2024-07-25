//
//  ChooseTrackerAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import UIKit

final class ChooseTrackerAssembly: ViewControllerAssembly {
    typealias Context = LifecycleManagingContext<TrackerKind, Never, ()>
    
    private let createTrackerAssembly: CreateTrackerAssembly
    
    init(createTrackerAssembly: CreateTrackerAssembly) {
        self.createTrackerAssembly = createTrackerAssembly
    }
    
    func assemble(_ context: Context) -> UIViewController {
        let presentationContext = NavigationPresentationContext()
        
        let router = ChooseTrackerRouter(
            createTrackerAssembly: createTrackerAssembly,
            presentationContext: presentationContext
        )
        
        let viewModel = ChooseTrackerViewModel(
            router: router,
            resultObserver: context.resultObserver
        )
        
        let viewController = ChooseTrackerViewController(viewModel: viewModel)
        
        return viewController
    }
}
