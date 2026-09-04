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

    func performCreate(
        _ block: @Sendable @escaping (PersistManagedObjectInitializable & PersistRawCreatable) -> Void
    ) async throws(PersistencyError) {
        do {
            try await managedObjectContext.perform {
                block(managedObjectContext)
                try saveContext()
            }
        }
        catch let e as PersistencyError {
            throw e
        }
        catch {
            throw .coreDataError(error)
        }
    }

    // MARK: - Read

    func perform<T>(
        _ block: @Sendable @escaping (PersistFetchableRecords) throws -> [T]
    ) async throws(PersistencyError) -> [T] {
        do {
            return try await managedObjectContext.perform {
                try block(managedObjectContext)
            }
        }
        catch let e as PersistencyError {
            throw e
        }
        catch {
            throw .coreDataError(error)
        }
    }

    func performOne<T>(
        _ block: @Sendable @escaping (PersistFetchableRecord) throws -> T
    ) async throws(PersistencyError) -> T {
        do {
            return try await managedObjectContext.perform {
                try block(managedObjectContext)
            }
        }
        catch let e as PersistencyError {
            throw e
        }
        catch {
            throw .coreDataError(error)
        }
    }

    func performCount(
        _ block: @Sendable @escaping (PersistCountable) throws -> Int
    ) async throws(PersistencyError) -> Int {
        do {
            return try await managedObjectContext.perform {
                try block(managedObjectContext)
            }
        }
        catch let e as PersistencyError {
            throw e
        }
        catch {
            throw .coreDataError(error)
        }
    }

    // MARK: - Update

    func performUpdateOrCreate(
        _ block: @Sendable @escaping (PersistRawCreatable & PersistRawFetchable) throws -> Void
    ) async throws(PersistencyError) {
        do {
            return try await managedObjectContext.perform {
                do {
                    try block(managedObjectContext)
                    try saveContext()
                }
                catch {
                    try rollback()
                }
            }
        }
        catch let e as PersistencyError {
            throw e
        }
        catch {
            throw .coreDataError(error)
        }
    }

    // MARK: - Delete

    func performRemove(
        _ block: @Sendable @escaping (PersistRemovable & PersistRawFetchable) throws -> Void
    ) async throws(PersistencyError) {
        do {
            return try await managedObjectContext.perform {
                try block(managedObjectContext)
                try saveContext()
            }
        }
        catch let e as PersistencyError {
            throw e
        }
        catch {
            throw .coreDataError(error)
        }
    }

    func deleteAllObjects<T: NSManagedObject>(_ type: T.Type) async throws(PersistencyError) where T: Entity {
        do {
            try await managedObjectContext.perform {
                let fetchRequest = NSFetchRequest<T>(entityName: type.entityName) as? NSFetchRequest<NSFetchRequestResult>
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest ?? .init(entityName: type.entityName))

                try managedObjectContext.execute(deleteRequest)
                try saveContext()
            }
        }
        catch let e as PersistencyError {
            throw e
        }
        catch {
            throw .coreDataError(error)
        }
    }
}

private extension PersistencyService {
    func saveContext() throws(PersistencyError) {
        guard managedObjectContext.hasChanges else {
            return
        }

        do {
            try managedObjectContext.save()
        }
        catch {
            try rollback()
        }
    }

    func rollback() throws(PersistencyError) {
        managedObjectContext.rollback()

        throw PersistencyError.rollback(
            contextName: managedObjectContext.name ?? "UnnamedContext",
            hasChanges: managedObjectContext.hasChanges
        )
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
