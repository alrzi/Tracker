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
        case .tab1: "Tab 1"
        case .tab2: "Tab 2"
        }
    }
    
    var image: UIImage {
        switch self {
        case .tab1: .actions
        case .tab2: .add
        }
    }
    
    var selectedImage: UIImage {
        switch self {
        case .tab1: .actions
        case .tab2: .add
        }
    }
}

