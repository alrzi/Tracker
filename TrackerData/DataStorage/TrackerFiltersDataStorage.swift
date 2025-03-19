//
//  TrackerFiltersDataStorage.swift
//  Tracker
//
//  Created by Александр Зиновьев on 24.08.2024.
//

import Foundation
import TrackerDomain
internal import DataStorage

extension TrackerFiltersDataStorage where Self: DataStorageProtocol {
    var trackerFilters: TrackerFilter {
        get {
            getCodableValue(
                key: TrackerFiltersDataStorageKey.trackerFilter,
                storage: .standard
            ) ?? .completedForDate
        }
        set {
            setCodableValue(
                newValue,
                key: TrackerFiltersDataStorageKey.trackerFilter,
                storage: .standard
            )
        }
    }
}

extension DataStorage: TrackerFiltersDataStorage { }

private enum TrackerFiltersDataStorageKey: String, DataStorageKey {
    case trackerFilter
}
