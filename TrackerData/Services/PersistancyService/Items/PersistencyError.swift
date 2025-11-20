//
//  PersistencyError.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 20.11.2025.
//

import Foundation

public enum PersistencyError: Error, Sendable {
    case rollback(contextName: String, hasChanges: Bool)
    case coreDataError(_ underlying: Error)
    case missingObject(predicate: String)
}
