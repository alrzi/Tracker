//
//  TrackerDataTests.swift
//  TrackerDataTests
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Testing
import CoreData
@testable import TrackerData

@Suite struct PersistencyServiceTests {
    @Test func performCreate_insertsEntity() async throws {
        // Given
        let containerProvider = InMemoryPersistentContainer()
        let service = PersistencyService(provider: containerProvider)

        // When
        try await service.performCreate {
            let entity: MockItemCoreData = $0.make(MockItemCoreData.self)
            entity.id = UUID()
            entity.title = "Test"
        }

        // Then
        let results = try containerProvider.persistentContainer.viewContext.fetch(MockItemCoreData.request())
        #expect(results.count == 1)
        #expect(results.first?.title == "Test")
    }

    @Test func performRead_returnsFetchedObjects() async throws {
        // Given
        let containerProvider = InMemoryPersistentContainer()
        let service = PersistencyService(provider: containerProvider)

        try await service.performCreate {
            for i in 0..<3 {
                let entity: MockItemCoreData = $0.make(MockItemCoreData.self)
                entity.id = UUID()
                entity.title = "Item \(i)"
            }
        }

        // When
        let fetched: [MockItem] = try await service.perform {
            try $0.fetchAll(MockItemCoreData.request())
        }

        // Then
        #expect(fetched.count == 3)
        #expect(fetched.map(\.title).contains("Item 1"))
    }

    @Test func performCreate_duplicateID_throws() async throws {
        // Given
        let containerProvider = InMemoryPersistentContainer()
        let service = PersistencyService(provider: containerProvider)
        let duplicateID = UUID()

        // Insert first object
        try await service.performCreate {
            let e: MockItemCoreData = $0.make(MockItemCoreData.self)
            e.id = duplicateID
            e.title = "Original"
        }

        // Insert second object with the same id
        try await service.performCreate {
            let e: MockItemCoreData = $0.make(MockItemCoreData.self)
            e.id = duplicateID
            e.title = "Duplicate"
        }

        // Verify both rows exist
        let results = try containerProvider.persistentContainer.viewContext.fetch(MockItemCoreData.request())
        #expect(results.count == 2)
        #expect(results.map(\.title).contains("Original"))
        #expect(results.map(\.title).contains("Duplicate"))
    }

    @Test func performRead_emptyStore_returnsEmptyArray() async throws {
        // Given
        let containerProvider = InMemoryPersistentContainer()
        let service = PersistencyService(provider: containerProvider)

        // When
        let fetched: [MockItem] = try await service.perform {
            try $0.fetchAll(MockItemCoreData.request())
        }

        // Then
        #expect(fetched.isEmpty)
    }

    @Test func performRead_fetchOneRaw_missingObject_throws404() async throws {
        // Given
        let containerProvider = InMemoryPersistentContainer()
        let service = PersistencyService(provider: containerProvider)

        // When / Then
        do {
            let _: MockItemCoreData = try await service.perform {
                try $0.fetchOneRaw(MockItemCoreData.request())
            }
            // If we get here the test should fail
            #expect(Bool(false), "Expected fetchOneRaw to throw, but it succeeded")
        }
        catch let err as NSError {
            #expect(err.domain == "CoreDataFetchError")
            #expect(err.code == 404)
        }
    }

    @Test func performRemove_nonExistentObject_noCrash() async throws {
        // Given
        let containerProvider = InMemoryPersistentContainer()
        let service = PersistencyService(provider: containerProvider)

        // Create a dummy object to obtain a reference type, then delete it immediately
        let dummy = try await service.performCreate { ctx in
            let obj: MockItemCoreData = ctx.make(MockItemCoreData.self)
            obj.id = UUID()
            obj.title = "Temp"
        }

        // Delete the object
        try await service.performRemove { ctx in
            if let toDelete = try? ctx.fetchOneRaw(MockItemCoreData.request()) {
                ctx.delete(toDelete)
            }
        }

        // Attempt to delete again – should not throw
        try await service.performRemove { ctx in
            if let toDelete = try? ctx.fetchOneRaw(MockItemCoreData.request()) {
                ctx.delete(toDelete)
            }
        }

        // Then – store should be empty
        let results = try containerProvider.persistentContainer.viewContext.fetch(MockItemCoreData.request())
        #expect(results.isEmpty)
    }

    @Test func performCount_emptyStore_returnsZero() async throws {
        // Given
        let containerProvider = InMemoryPersistentContainer()
        let service = PersistencyService(provider: containerProvider)

        // When
        let count = try await service.performCount { ctx in
            try ctx.fetchCount(MockItemCoreData.request())
        }

        // Then
        #expect(count == 0)
    }

    @Test func performCount_afterInserts_returnsCorrectNumber() async throws {
        // Given
        let containerProvider = InMemoryPersistentContainer()
        let service = PersistencyService(provider: containerProvider)

        try await service.performCreate { ctx in
            for i in 0..<5 {
                let entity: MockItemCoreData = ctx.make(MockItemCoreData.self)
                entity.id = UUID()
                entity.title = "Item \(i)"
            }
        }

        // When
        let count = try await service.performCount { ctx in
            try ctx.fetchCount(MockItemCoreData.request())
        }

        // Then
        #expect(count == 5)
    }
}
