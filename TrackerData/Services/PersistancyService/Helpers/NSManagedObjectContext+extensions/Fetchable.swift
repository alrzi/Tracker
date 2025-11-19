//
//  Fetchable.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 19.11.2025.
//

import Foundation
import CoreData

protocol Fetchable: Sendable {
    func fetchAll<R, T>(_ request: NSFetchRequest<R>) throws -> [T]
    where
    R : NSFetchRequestResult,
    T : Sendable & Initable<R>

    func fetchOne<R, T>(_ request: NSFetchRequest<R>) throws -> T
    where
    R : NSFetchRequestResult,
    T : Sendable & Initable<R>

    func fetchOneRaw<R>(_ request: NSFetchRequest<R>) throws -> R
    where R : NSFetchRequestResult
}

extension NSManagedObjectContext: Fetchable {
    func fetchAll<R, T>(_ request: NSFetchRequest<R>) throws -> [T]
    where
    R : NSFetchRequestResult,
    T : Sendable & Initable<R>
    {
        try fetch(request)
            .map { T(object: $0) }
    }

    func fetchOne<R, T>(_ request: NSFetchRequest<R>) throws -> T
    where
    R : NSFetchRequestResult,
    T : Sendable & Initable<R>
    {
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
    where R : NSFetchRequestResult
    {
        let obj = try fetch(request)
            .first

        guard let obj else {
            throw NSError(
                domain: "CoreDataFetchError",
                code: 404,
                userInfo: [
                    NSLocalizedDescriptionKey: "No object of type \(R.self) matches the supplied fetch request.",
                    // Optional: include the request’s predicate for debugging
                    "FetchPredicate": request.predicate?.description ?? "none"
                ]
            )
        }

        return obj
    }
}
