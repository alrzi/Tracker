//
//  DataStorageType.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 04.11.2025.
//

import Foundation
internal import DataStorage

enum DataStorageType: DataStorageTypeProtocol {
    case base

    static var `default`: DataStorageType { .base }
}
