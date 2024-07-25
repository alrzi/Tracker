//
//  FiltersAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 13.07.2024.
//

import UIKit

final class FiltersAssembly: ViewControllerAssembly {
    typealias Context =  LifecycleManagingContext<TrackerFilters, Never, TrackerFilters>
    
    func assemble(_ context: Context) -> UIViewController {
        FiltersViewController(
            filter: context.configuration,
            onFilterSelected: {
                context.resultObserver.send($0)
                context.closingContext.close()
            }
        )
    }
}
