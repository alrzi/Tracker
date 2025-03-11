//
//  CategoriesListViewModelError.swift
//  Tracker
//
//  Created by Александр Зиновьев on 25.07.2024.
//

import Foundation
import TrackerDomain

enum CategoriesListViewModelError: Error {
    case onCategorySelected(TrackerSection)
}
