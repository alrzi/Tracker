//
//  PersistCountable.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 19.11.2025.
//

import Foundation
import CoreData

protocol PersistCountable: Sendable {
    func fetchCount<R>(_ request: NSFetchRequest<R>) throws -> Int where R: NSFetchRequestResult
}

extension NSManagedObjectContext: PersistCountable {
    func fetchCount<R>(_ request: NSFetchRequest<R>) throws -> Int where R: NSFetchRequestResult {
        try count(for: request)
    }
}

