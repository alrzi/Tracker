//
//  PersistManagedObjectInitializable.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 19.11.2025.
//

import Foundation
import CoreData

protocol PersistManagedObjectInitializable: Sendable {
    func make<T, V>(_ type: T.Type, from: V) where T: NSManagedObject & CopyableEntity<V>
}

extension NSManagedObjectContext: PersistManagedObjectInitializable {
    func make<T, V>(_ type: T.Type, from plain: V) where T: NSManagedObject & CopyableEntity<V> {
        let t = T(context: self)
        t.copy(from: plain)
    }
}
