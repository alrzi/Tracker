//
//  FetchingOne.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 20.11.2025.
//

import Foundation
import CoreData

protocol FetchingOne: Sendable {
    func fetchOne<R, T>(_ request: NSFetchRequest<R>) throws -> T
    where R : NSFetchRequestResult, T : Sendable & Initable<R>

    func fetchOneRaw<R>(_ request: NSFetchRequest<R>) throws -> R
    where R : NSFetchRequestResult
}

extension NSManagedObjectContext: FetchingOne {
    func fetchOne<R, T>(_ request: NSFetchRequest<R>) throws -> T
    where R : NSFetchRequestResult, T : Sendable & Initable<R> {
        let obj = try fetch(request)
            .first
            .map { T(object: $0) }

        guard let obj else {
            throw NSError(
                domain: "CoreDataFetchError",
                code: 404,
                userInfo: [
                    NSLocalizedDescriptionKey: "No object of type \(T.self) matches the supplied fetch request.",
                    "FetchPredicate": request.predicate?.description ?? "none"
                ]
            )
        }

        return obj
    }

    func fetchOneRaw<R>(_ request: NSFetchRequest<R>) throws -> R
    where R : NSFetchRequestResult {
        let obj = try fetch(request)
            .first

        guard let obj else {
            throw NSError(
                domain: "CoreDataFetchError",
                code: 404,
                userInfo: [
                    NSLocalizedDescriptionKey: "No object of type \(R.self) matches the supplied fetch request.",
                    "FetchPredicate": request.predicate?.description ?? "none"
                ]
            )
        }

        return obj
    }
}
