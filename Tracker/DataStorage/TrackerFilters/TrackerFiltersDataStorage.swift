//
//  TrackerFiltersDataStorage.swift
//  Tracker
//
//  Created by Александр Зиновьев on 24.08.2024.
//

import Foundation

protocol TrackerFiltersDataStorage: AnyObject {
    var trackerFilters: TrackerFilters { get set }
}

extension TrackerFiltersDataStorage where Self: DataStorageProtocol {
    var trackerFilters: TrackerFilters {
        get {
            getCodableValue(key: ChecklistDataStorageKey.trackerFilter, storage: .standard) ?? .completedForDate
        }
        set {
            setCodableValue(newValue, key: ChecklistDataStorageKey.trackerFilter, storage: .standard)            
        }
    }
}

extension DataStorage: TrackerFiltersDataStorage { }

private enum ChecklistDataStorageKey: String, DataStorageKey {
    case trackerFilter
}
