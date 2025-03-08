import CoreData

public final class PersistencyService {
    private lazy var persistentContainer: NSPersistentContainer = {
        let persistentStore = NSPersistentStoreDescription()
        persistentStore.shouldMigrateStoreAutomatically = true
        persistentStore.shouldInferMappingModelAutomatically = true
        
        let container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)
        
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
        
        return container
    }()

    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()

    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard
            let modelURL = Bundle.main.url(forResource: modelName, withExtension: ".momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL)
        else {
            fatalError("[Error]: Unable to load model.")
        }
        
        return model
    }()

    private lazy var sqliteURL: URL = {
        do {
            let fileURL = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            .appendingPathComponent("Tracker.sqlite")
            
            return fileURL
        }
        catch {
            fatalError("[Error]: \(error.localizedDescription)")
        }
    }()
    
    private let modelName: String = "Tracker"

    public init() { }
}

public enum PersistencyServiceError: Error {
    case notSaved
}

public extension PersistencyService {
    func fetchObjects<T: NSManagedObject>(_ type: T.Type) -> [T] where T: Entity {
        let fetchRequest = NSFetchRequest<T>(entityName: type.entityName)
        
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            return result
        } 
        catch {
            debugPrint(error.localizedDescription)
        }
        
        return []
    }

    func fetchObjects<T: NSManagedObject>(with fetchRequest: NSFetchRequest<T>) -> [T] {
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            return result
        } 
        catch {
            debugPrint(error.localizedDescription)
        }
        
        return []
    }

    func fetchCount<T: NSManagedObject>(with fetchRequest: NSFetchRequest<T>) -> Int {
        do {
            let count = try managedObjectContext.count(for: fetchRequest)
            return count
        } 
        catch {
            debugPrint(error.localizedDescription)
            return 0
        }
    }

    func createObject<T: NSManagedObject>(_ type: T.Type) -> T {
        T(context: managedObjectContext)
    }

    func saveContext() {
        guard managedObjectContext.hasChanges else {
            return
        }
        
        do {
            try managedObjectContext.save()
        } 
        catch {
            managedObjectContext.rollback()
            debugPrint(error.localizedDescription)
        }
    }

    func removeObject(_ object: NSManagedObject) {
        managedObjectContext.delete(object)        
    }
    
    func deleteAllObjects<T: NSManagedObject>(_ type: T.Type) where T: Entity {
        let fetchRequest = NSFetchRequest<T>(entityName: type.entityName)
        let deleteRequest = NSBatchDeleteRequest(
            fetchRequest: fetchRequest as? NSFetchRequest<NSFetchRequestResult> ?? .init(entityName: type.entityName)
        )

        do {
            try managedObjectContext.execute(deleteRequest)
        } 
        catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    func fetchObject<T, V>(
        _ type: T.Type,
        by keyPath: KeyPath<T, V>,
        value: V
    ) -> [T]? where T: NSManagedObject & Entity {
        let fetchRequest = NSFetchRequest<T>(entityName: type.entityName)
        
        let key = NSExpression(forKeyPath: keyPath).keyPath
        
        fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: [key, value])

        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            return result
        } 
        catch {
            debugPrint(error.localizedDescription)
        }

        return nil
    }
    
    func object<T: NSManagedObject>(_ type: T.Type, with moID: NSManagedObjectID) -> T? {
        do {
            let object = try managedObjectContext.existingObject(with: moID)
            return object as? T
        } 
        catch {
            return nil
        }
    }
    
    
    func fetchObject<T: NSManagedObject>(with fetchRequest: NSFetchRequest<T>) async throws -> [T] {
        try await managedObjectContext.perform {
            return try self.managedObjectContext.fetch(fetchRequest)
        }
    }
    
    func fetchObjects<T: NSManagedObject>(_ type: T.Type) async throws -> [T] where T: Entity {
        let fetchRequest = NSFetchRequest<T>(entityName: type.entityName)
        
        return try await managedObjectContext.perform {
            return try self.managedObjectContext.fetch(fetchRequest)
        }
        
        return []
    }
}
