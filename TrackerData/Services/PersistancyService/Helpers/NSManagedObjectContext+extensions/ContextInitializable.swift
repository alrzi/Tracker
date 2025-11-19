//
//  ContextInitializable.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 19.11.2025.
//

import Foundation
import CoreData

protocol ContextInitializable: Sendable {
    func make<T>(_ type: T.Type) -> T where T: NSManagedObject
}

extension NSManagedObjectContext: ContextInitializable {
    func make<T>(_ type: T.Type) -> T where T: NSManagedObject {
        T(context: self)
    }
}
