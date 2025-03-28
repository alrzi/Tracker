//
//  TabItem.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import UIKit

enum TabItem: Int, CaseIterable {
    case tab1 = 0
    case tab2 = 1
    
    var title: String {
        switch self {
        case .tab1: R.string.localizable.tabBarTrackers()
        case .tab2: R.string.localizable.tabBarStatistics()
        }
    }
    
    var image: UIImage {
        switch self {
        case .tab1: R.image.leftTabBar()!
        case .tab2: R.image.rightTabBar()!
        }
    }
    
    var selectedImage: UIImage {
        image
    }
}
