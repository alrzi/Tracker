//
//  TabBarViewRouter.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import Foundation
import UIKit

struct TabBarViewRouter {
    let trackersAssembly: TrackersAssembly
    let statisticAssembly: StatisticsAssembly
    let tabBarPresentationContext: TabBarPresentationContext
    
    @MainActor
    func setupViewControllers(for sections: [TabBarSection]) {
        guard let tabBarController = tabBarPresentationContext.tabBarController else {
            return
        }
        
        let viewControllers = sections.map {
            let viewController: UIViewController = switch $0 {
            case .trackers: trackersAssembly.assemble()
            case .statistics: statisticAssembly.assemble()
            }
            
            viewController.tabBarItem = UITabBarItem(section: $0)
            
            return viewController
        }
        
        tabBarController.setViewControllers(viewControllers, animated: false)
    }
}

// MARK: - Private

private extension UITabBarItem {
    convenience init(section: TabBarSection) {
        self.init(
            title: section.title,
            image: section.image.withTintColor(UIColor(resource: .cBlue)).withRenderingMode(.alwaysOriginal),
            selectedImage: section.image.withTintColor(UIColor(resource: .cBlue)).withRenderingMode(.alwaysOriginal)
        )
        
        imageInsets = .zero
        accessibilityIdentifier = "Tab_\(section)"
    }
}

private extension TabBarSection {
    var title: String {
        switch self {
        case .trackers: R.string.localizable.tabBarTrackers()
        case .statistics: R.string.localizable.tabBarStatistics()
        }
    }
    
    var image: UIImage {
        switch self {
        case .trackers: UIImage(resource: ._01LeftTabBar)
        case .statistics: UIImage(resource: ._02RightTabBar)
        }
    }
}
