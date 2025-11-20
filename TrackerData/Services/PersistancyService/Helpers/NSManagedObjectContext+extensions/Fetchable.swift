//
//  FetchingAll.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 19.11.2025.
//

import Foundation
import CoreData

protocol FetchingAll: Sendable {
    func fetchAll<R, T>(_ request: NSFetchRequest<R>) throws -> [T]
    where R : NSFetchRequestResult, T : Sendable & Initable<R>
}

extension NSManagedObjectContext: FetchingAll {
    func fetchAll<R, T>(_ request: NSFetchRequest<R>) throws -> [T]
    where R : NSFetchRequestResult, T : Sendable & Initable<R> {
        try fetch(request)
            .map { T(object: $0) }
    }
}
