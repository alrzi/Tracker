//
//  PersistentContainerProvider.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 10.04.2025.
//

import Foundation
import CoreData

final class PersistentContainerProvider: PersistentContainerProviding {
    let persistentContainer: NSPersistentContainer
    
    init(
        fileManager: FileManager = .default,
        modelName: String
    ) {
        let bundle = Bundle(for: Self.self)
        
        guard
            let modelURL = bundle.url(forResource: modelName, withExtension: ".momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL)
        else {
            fatalError("[Error]: Unable to load model.")
        }
        
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        
        let persistentStore = NSPersistentStoreDescription()
        persistentStore.shouldMigrateStoreAutomatically = true
        persistentStore.shouldInferMappingModelAutomatically = true
        
        do {
            let coordinator = container.persistentStoreCoordinator
            
            if let oldStore = coordinator.persistentStores.first {
                try coordinator.remove(oldStore)
            }
            
            let sqliteURL = try fileManager
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("\(modelName).sqlite")
            
            _ = try coordinator.addPersistentStore(type: .sqlite, at: sqliteURL)
        }
        catch {
            fatalError("[Error]: \(error.localizedDescription)")
        }
        
        container.persistentStoreDescriptions = [persistentStore]
        
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("[Error]: \(error.localizedDescription)")
            }
        }
        
        self.persistentContainer = container
    }
}
