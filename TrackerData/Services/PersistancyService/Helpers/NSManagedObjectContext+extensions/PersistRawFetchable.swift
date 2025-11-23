//
//  PersistRawFetchable.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 23.11.2025.
//

import Foundation
import CoreData

protocol PersistRawFetchable: Sendable {
    func fetchOneRaw<R>(_ request: NSFetchRequest<R>) throws(PersistencyError) -> R
    where R : NSFetchRequestResult
}

extension NSManagedObjectContext: PersistRawFetchable {
    func fetchOneRaw<R>(_ request: NSFetchRequest<R>) throws(PersistencyError) -> R
    where R : NSFetchRequestResult {
        do {
            let obj = try fetch(request)
                .first

            guard let obj else {
                throw PersistencyError.missingObject(predicate: request.predicate.debugDescription)
            }

            return obj
        }
        catch let e as PersistencyError {
            throw e
        }
        catch {
            throw .coreDataError(error)
        }
    }
}
