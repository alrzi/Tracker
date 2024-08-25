//
//  CategoryCreationAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import UIKit
import Presentation

final class CategoryCreationAssembly: ViewControllerAssembly {
    typealias Context = LifecycleManagingContext<(), Never, CategoryCreationViewModel.Mode>
    
    private let categoryRepository: CategoryRepository
    
    init(categoryRepository: CategoryRepository) {
        self.categoryRepository = categoryRepository
    }
    
    func assemble(_ context: Context) -> UIViewController {
        let viewModel = CategoryCreationViewModel(
            categoryRepository: categoryRepository,
            mode: context.configuration,
            onCreateCategory: { context.closingContext.close() },
            onDeinit: { /*context.resultObserver.send(completion: .finished)*/ }
        )
        
        let viewController = CategoryCreationViewController(viewModel: viewModel)
        
        return viewController
    }
}
