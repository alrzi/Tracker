//
//  InMemoryPersistentContainer.swift
//  TrackerDataTests
//
//  Created by Александр Зиновьев on 20.11.2025.
//

import Foundation
import CoreData
@testable import TrackerData

final class InMemoryPersistentContainer: PersistentContainerProviding {
    let persistentContainer: NSPersistentContainer

    init(modelName: String = "MockItemCoreData") {
        let bundle = Bundle(for: Self.self)

        guard
            let modelURL = bundle.url(forResource: modelName, withExtension: ".momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL)
        else {
            fatalError("[Error]: Unable to load model.")
        }

        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            precondition(error == nil, "Failed to load in‑memory store: \(error!)")
        }
        self.persistentContainer = container
    }
}
