//
//  PersistRemovable.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 19.11.2025.
//

import Foundation
import CoreData

protocol PersistRemovable: Sendable {
    func delete<T>(_ object: T) where T: NSManagedObject
}

extension NSManagedObjectContext: PersistRemovable {
    func delete<T>(_ object: T) where T: NSManagedObject {
        self.delete(object)
    }
}
