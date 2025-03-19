//
//  TrackerFiltersDataStorage.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Foundation

public protocol TrackerFiltersDataStorage: AnyObject {
    var trackerFilters: TrackerFilter { get set }
}
