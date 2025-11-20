//
//  FetchingOne.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 20.11.2025.
//

import Foundation
import CoreData

protocol FetchingOne: Sendable {
    func fetchOne<R, T>(_ request: NSFetchRequest<R>) throws(PersistencyError) -> T
    where R : NSFetchRequestResult, T : Sendable & Initable<R>

    func fetchOneRaw<R>(_ request: NSFetchRequest<R>) throws(PersistencyError) -> R
    where R : NSFetchRequestResult
}

extension NSManagedObjectContext: FetchingOne {
    func fetchOne<R, T>(_ request: NSFetchRequest<R>) throws(PersistencyError) -> T
    where R : NSFetchRequestResult, T : Sendable & Initable<R> {
        do {
            let obj = try fetch(request)
                .first
                .map { T(object: $0) }

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
