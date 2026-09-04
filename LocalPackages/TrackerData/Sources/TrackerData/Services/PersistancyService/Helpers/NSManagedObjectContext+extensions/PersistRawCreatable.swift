//
//  Updating.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 23.11.2025.
//

import Foundation
import CoreData

protocol PersistRawCreatable: Sendable {
    func create<T, V>(_ type: T.Type, from: V) -> T where T: NSManagedObject & CopyableEntity<V>
}

extension NSManagedObjectContext: PersistRawCreatable {
    func create<T, V>(_ type: T.Type, from plain: V) -> T where T: NSManagedObject & CopyableEntity<V> {
        let t = T(context: self)
        t.copy(from: plain)
        return t
    }
}
