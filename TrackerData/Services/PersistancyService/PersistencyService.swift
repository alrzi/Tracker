import CoreData

enum PersistencyError: Error {
    case noObjectFound
    case failedToSave
}

final class PersistencyService: Sendable {
    private let modelName: String = "Tracker"
    private let persistentContainer: NSPersistentContainer
    nonisolated(unsafe) private let managedObjectContext: NSManagedObjectContext
    
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
    
    // MARK: - Create
    
    func createObject<T, C>(_ type: T.Type, from domain: C) async throws
    where T: NSManagedObject & CopyableEntity<C>
    {
        try await managedObjectContext.perform {
            let newObject = T(context: self.managedObjectContext)
            newObject.copy(from: domain)
            
            try self.saveContext()
        }
    }
    
    func createObjectAddObjectToIt<T, C, E, R>(_ type: T.Type, from domain: C, _ subType: E.Type, entityToAddTo: R) async throws
    where
    T: NSManagedObject & CopyableEntity<C> & ValueAddable<E>,
    E: NSManagedObject & CopyableEntity<R>
    {
        try await managedObjectContext.perform {
            let newObject = T(context: self.managedObjectContext)
            newObject.copy(from: domain)
            
            let parentObject = E(context: self.managedObjectContext)
            parentObject.copy(from: entityToAddTo)
            
            newObject.addValue(parentObject)
            
            try self.saveContext()
        }
    }
    
    func createObjectAndAddToEntity<T, C, E, R>(_ type: T.Type, from domain: [C], _ subType: E.Type, entityToAddTo: R) async throws
    where
    T: NSManagedObject & CopyableEntity<C>,
    E: NSManagedObject & CopyableEntity<R> & SetAddable<T>
    {
        try await managedObjectContext.perform {
            var objects: Set<T> = []
            for i in domain {
                let newObject = T(context: self.managedObjectContext)
                newObject.copy(from: i)
                objects.insert(newObject)
            }
            
            let parentObject = E(context: self.managedObjectContext)
            parentObject.copy(from: entityToAddTo)
            parentObject.addElement(objects)
            
            try self.saveContext()
        }
    }
    
    func createObject<T, C, D>(_ type: T.Type, from domain: C, andAddObjectFor request: NSFetchRequest<D>) async throws
    where
    T: NSManagedObject & ValueAddable<D> & CopyableEntity<C>
    {
        try await managedObjectContext.perform {
            guard let objectToAdd = try self.managedObjectContext.fetch(request).first else {
                throw PersistencyError.noObjectFound
            }
            
            let object = T(context: self.managedObjectContext)
            object.copy(from: domain)
            object.addValue(objectToAdd)
            
            try self.saveContext()
        }
    }
    
    // MARK: - Read
    
    func fetchObjects<T, R>(with fetchRequest: NSFetchRequest<T>) async throws -> [R]
    where R: Initable<T>
    {
        try await managedObjectContext.perform {
            try self.managedObjectContext.fetch(fetchRequest).map { .init(object: $0) }
        }
    }
    
    func fetchObject<T, R>(with fetchRequest: NSFetchRequest<T>) async throws -> R?
    where R: Initable<T>
    {
        try await managedObjectContext.perform {
            try self.managedObjectContext.fetch(fetchRequest).first.map { .init(object: $0) }
        }
    }
    
    func fetchObjects<T: NSManagedObject, R>(_ type: T.Type) async throws -> [R]
    where
    T: Entity,
    R: Initable<T>
    {
        try await managedObjectContext.perform {
            try self.managedObjectContext.fetch(NSFetchRequest<T>(entityName: type.entityName)).map { .init(object: $0) }
        }
    }
    
    func fetchCount<T: NSManagedObject>(with fetchRequest: NSFetchRequest<T>) async throws -> Int {
        try await managedObjectContext.perform {
            try self.managedObjectContext.count(for: fetchRequest)
        }
    }
    
    // MARK: - Update
    
    func updateObject<T, C>(for request: NSFetchRequest<T>, with info: C) async throws
    where T: CopyableEntity<C>
    {
        try await managedObjectContext.perform {
            guard let object = try self.managedObjectContext.fetch(request).first else {
                throw PersistencyError.noObjectFound
            }
            
            object.copy(from: info)
            
            try self.saveContext()
        }
    }
    
    func updateObject<T, A>(for request: NSFetchRequest<T>, withObjectForRequest anotherRequest: NSFetchRequest<A>) async throws
    where T: ValueAddable<A>
    {
        try await managedObjectContext.perform {
            guard let object = try self.managedObjectContext.fetch(request).first else {
                throw PersistencyError.noObjectFound
            }
            
            guard let anotherObject = try self.managedObjectContext.fetch(anotherRequest).first else {
                throw PersistencyError.noObjectFound
            }
            
            object.addValue(anotherObject)
            
            try self.saveContext()
        }
    }
    
    // MARK: - Delete
    
    func removeObject<T: NSManagedObject>(for request: NSFetchRequest<T>) async throws {
        try await managedObjectContext.perform {
            guard let object = try self.managedObjectContext.fetch(request).first else {
                throw PersistencyError.noObjectFound
            }
            
            self.managedObjectContext.delete(object)
            try self.saveContext()
        }
    }
    
    func deleteAllObjects<T: NSManagedObject>(_ type: T.Type) async throws where T: Entity {
        try await managedObjectContext.perform {
            let fetchRequest = NSFetchRequest<T>(entityName: type.entityName) as? NSFetchRequest<NSFetchRequestResult>
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest ?? .init(entityName: type.entityName))
            
            try self.managedObjectContext.execute(deleteRequest)
            try self.saveContext()
        }
    }
}

private extension PersistencyService {
    func saveContext() throws {
        guard self.managedObjectContext.hasChanges else {
            return
        }
        
        do {
            try self.managedObjectContext.save()
        }
        catch {
            self.managedObjectContext.rollback()
            
            throw PersistencyError.failedToSave
        }
    }
}
