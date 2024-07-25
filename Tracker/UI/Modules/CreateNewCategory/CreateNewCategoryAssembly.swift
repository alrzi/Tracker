//
//  CreateNewCategoryAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import UIKit

final class CreateNewCategoryAssembly: ViewControllerAssembly {
    typealias Context =  LifecycleManagingContext<(), Never, CreateNewCategoryViewModel.Mode>
    
    private let categoryRepository: CategoryRepository
    
    init(categoryRepository: CategoryRepository) {
        self.categoryRepository = categoryRepository
    }
    
    func assemble(_ context: Context) -> UIViewController {
        let viewModel = CreateNewCategoryViewModel(
            categoryRepository: categoryRepository,
            mode: context.configuration,
            onCreateCategory: { context.closingContext.close() },
            onDeinit: { context.resultObserver.send(completion: .finished) }
        )
        
        let viewController = CreateNewCategoryViewController(viewModel: viewModel)
        
        return viewController
    }
}
