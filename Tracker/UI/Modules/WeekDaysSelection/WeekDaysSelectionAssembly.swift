//
//  WeekDaysSelectionAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import UIKit

final class WeekDaysSelectionAssembly: ViewControllerAssembly {
    typealias WeekDays = Set<Int>
    typealias Context =  LifecycleManagingContext<WeekDays, Never, WeekDays>
    
    func assemble(_ context: Context) -> UIViewController {
        let viewController = WeekDaysSelectionViewController(
            weekDays: context.configuration,
            weekDaysToShow: {
                context.resultObserver.send($0)
                context.closingContext.close()
            }
        )
        
        return viewController
    }
}
