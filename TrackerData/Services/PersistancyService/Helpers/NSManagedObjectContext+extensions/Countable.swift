//
//  Countable.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 19.11.2025.
//

import Foundation
import CoreData

protocol Countable: Sendable {
    func fetchCount<R>(_ request: NSFetchRequest<R>) throws -> Int where R: NSFetchRequestResult
}

extension NSManagedObjectContext: Countable {
    func fetchCount<R>(_ request: NSFetchRequest<R>) throws -> Int where R: NSFetchRequestResult {
        try count(for: request)
    }
}
