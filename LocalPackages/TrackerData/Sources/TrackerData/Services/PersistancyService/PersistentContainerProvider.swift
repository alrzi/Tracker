//
//  PersistentContainerProvider.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 10.04.2025.
//

import CoreData
import Foundation

protocol PersistentContainerProviding: AnyObject, Sendable {
    var persistentContainer: NSPersistentContainer { get }
}

final class PersistentContainerProvider: PersistentContainerProviding {
    let persistentContainer: NSPersistentContainer

    init(
        fileManager: FileManager = .default,
        modelName: String
    ) {
        let bundle = Bundle.module

        guard
            let modelURL = bundle.url(forResource: modelName, withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL)
        else {
            fatalError("[Error]: Unable to load model.")
        }

        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        let coordinator = container.persistentStoreCoordinator

        do {
            if let oldStore = coordinator.persistentStores.first {
                try coordinator.remove(oldStore)
            }

            let sqliteURL =
                try fileManager
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("\(modelName).sqlite")

            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true,
            ]

            _ = try coordinator.addPersistentStore(type: .sqlite, at: sqliteURL, options: options)
        }
        catch {
            fatalError("[Error]: \(error.localizedDescription)")
        }

        container.loadPersistentStores { description, error in
            if let error {
                fatalError("[Error]: \(error.localizedDescription) [Description]: \(description)")
            }
        }

        self.persistentContainer = container
    }
}
