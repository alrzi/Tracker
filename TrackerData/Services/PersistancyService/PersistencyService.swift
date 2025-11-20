import CoreData
import Combine
import TrackerDomain

struct PersistencyService: Sendable {
    private let persistentContainer: NSPersistentContainer
    private let managedObjectContext: NSManagedObjectContext
    
    init(provider: PersistentContainerProviding) {
        self.persistentContainer = provider.persistentContainer
        self.managedObjectContext = persistentContainer.newBackgroundContext()
        managedObjectContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        managedObjectContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: - Observe

    func observe(_ changeTypes: Set<ChangeType>) -> AsyncPublisher<Publishers.CompactMap<NotificationCenter.Publisher, Set<ChangeType>>> {
        NotificationCenter.default.publisher(
            for: NSManagedObjectContext.didSaveObjectIDsNotification,
            object: managedObjectContext
        )
        .compactMap { notification in
            Set(
                changeTypes
                    .compactMap { type in
                        guard (notification.userInfo?[type.userInfoKey] as? Set<NSManagedObjectID>) != nil else {
                            return nil
                        }
                        
                        return type
                    }
            )
        }
        .values
    }
    
    // MARK: - Create

    func performCreate(_ block: @Sendable @escaping (ContextInitializable) throws -> Void) async throws {
        try await managedObjectContext.perform {
            try block(managedObjectContext)
            try self.saveContext()
        }
    }

    // MARK: - Read

    func perform<T>(_ block: @Sendable @escaping (Fetchable) throws -> [T]) async throws -> [T] {
        try await managedObjectContext.perform {
            try block(managedObjectContext)
        }
    }

    func perform<T>(_ block: @Sendable @escaping (Fetchable) throws -> T) async throws -> T {
        try await managedObjectContext.perform {
            try block(managedObjectContext)
        }
    }

    func performCount(_ block: @Sendable @escaping (Countable) throws -> Int) async throws -> Int {
        try await managedObjectContext.perform {
            try block(managedObjectContext)
        }
    }

    // MARK: - Update

    func performUpdateOrCreate(_ block: @Sendable @escaping (ContextInitializable & Fetchable) throws -> Void) async throws {
        try await managedObjectContext.perform {
            try block(managedObjectContext)
            try self.saveContext()
        }
    }

    // MARK: - Delete

    func performRemove(_ block: @Sendable @escaping (Removable & Fetchable) throws -> Void) async throws {
        try await managedObjectContext.perform {
            try block(managedObjectContext)
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

            throw NSError(
                domain: "PersistencyServiceError",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Failed to persist changes to the Core Data store.",
                    "ContextName": managedObjectContext.name ?? "UnnamedContext",
                    "HasChanges": managedObjectContext.hasChanges
                ]
            )
        }
    }
}

private extension ChangeType {
    var userInfoKey: String {
        switch self {
        case .inserted: NSInsertedObjectIDsKey
        case .deleted: NSDeletedObjectIDsKey
        case .updated: NSUpdatedObjectIDsKey
        }
    }
}
