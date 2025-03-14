import CoreData

final actor PersistencyService: @unchecked Sendable {
    private let modelName: String = "Tracker"
    private let persistentContainer: NSPersistentContainer
    private let managedObjectContext: NSManagedObjectContext

    init() {
        let bundle = Bundle(for: type(of: self))
        
        guard
            let modelURL = bundle.url(forResource: modelName, withExtension: ".momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL)
        else {
            fatalError("[Error]: Unable to load model.")
        }
        
        let sqliteURL = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appendingPathComponent("Tracker.sqlite")
        
        guard let sqliteURL else {
            fatalError("[Error]: Unable to load model.")
        }
        
        let persistentStore = NSPersistentStoreDescription()
        persistentStore.shouldMigrateStoreAutomatically = true
        persistentStore.shouldInferMappingModelAutomatically = true
        
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        
        do {
            let coordinator = container.persistentStoreCoordinator
            
            if let oldStore = coordinator.persistentStores.first {
                try coordinator.remove(oldStore)
            }
            
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
        
        persistentContainer = container
        managedObjectContext = container.newBackgroundContext()
    }
}

extension PersistencyService {
    func fetchObjects<T: NSManagedObject>(with fetchRequest: NSFetchRequest<T>) async throws -> [T] {
        try await managedObjectContext.perform {
            try self.managedObjectContext.fetch(fetchRequest)
        }
    }
    
    func fetchObject<T: NSManagedObject>(with fetchRequest: NSFetchRequest<T>) async throws -> T? where T: Entity {
        try await managedObjectContext.perform {
            try self.managedObjectContext.fetch(fetchRequest).first
        }
    }
    
    func fetchObjects<T: NSManagedObject>(_ type: T.Type) async throws -> [T] where T: Entity {
        try await managedObjectContext.perform {
            try self.managedObjectContext.fetch(NSFetchRequest<T>(entityName: type.entityName))
        }
    }
    
    func fetchCount<T: NSManagedObject>(with fetchRequest: NSFetchRequest<T>) async throws -> Int {
        try await managedObjectContext.perform {
            try self.managedObjectContext.count(for: fetchRequest)
        }
    }
    
    func createObject<T: NSManagedObject>(_ type: T.Type) async -> T {
        await managedObjectContext.perform {
            T(context: self.managedObjectContext)
        }
    }
    
    func saveContext() async {
        await managedObjectContext.perform {
            guard self.managedObjectContext.hasChanges else {
                return
            }
            
            do {
                try self.managedObjectContext.save()
            }
            catch {
                self.managedObjectContext.rollback()
                debugPrint(error.localizedDescription)
            }
        }
    }

    func removeObject(_ object: NSManagedObject) async {
        await managedObjectContext.perform {
            self.managedObjectContext.delete(object)
        }
    }
    
    func deleteAllObjects<T: NSManagedObject>(_ type: T.Type) async throws where T: Entity {
        try await managedObjectContext.perform {
            let fetchRequest = NSFetchRequest<T>(entityName: type.entityName) as? NSFetchRequest<NSFetchRequestResult>
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest ?? .init(entityName: type.entityName))
            
            try self.managedObjectContext.execute(deleteRequest)
        }
    }
}
