//
//  ChooseScheduleAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import UIKit

final class ChooseScheduleAssembly: ViewControllerAssembly {
    typealias Context =  LifecycleManagingContext<(), Never, ()>
    
    func assemble(_ context: Context) -> UIViewController {
        let viewController = ChooseScheduleViewController(weekDays: [1])
        
        return viewController
    }
}
