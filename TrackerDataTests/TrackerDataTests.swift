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
        let sut = PersistencyService(provider: InMemoryPersistentContainer())

        // When
        try await sut.performCreate { $0.make(MockItemCoreData.self, from: MockItem(title: "Test")) }

        // Then
        let results: [MockItem] = try await sut.perform { try $0.fetchAll(MockItemCoreData.request()) }
        #expect(results.count == 1)
        #expect(results.first?.title == "Test")
    }

    @Test func performRead_returnsFetchedObjects() async throws {
        // Given
        let sut = PersistencyService(provider: InMemoryPersistentContainer())

        try await sut.performCreate {
            for i in 0..<3 {
                $0.make(MockItemCoreData.self, from: MockItem(title: "Item \(i)"))
            }
        }

        // When
        let fetched: [MockItem] = try await sut.perform { try $0.fetchAll(MockItemCoreData.request()) }

        // Then
        #expect(fetched.count == 3)
        #expect(fetched.map(\.title).contains("Item 1"))
    }

    @Test func performCreate_duplicateID() async throws {
        // Given
        let sut = PersistencyService(provider: InMemoryPersistentContainer())
        let duplicateID = UUID()

        // When
        try await sut.performCreate {
            $0.make(MockItemCoreData.self, from: MockItem(id: duplicateID, title: "Original"))
        }

        try await sut.performCreate {
            $0.make(MockItemCoreData.self, from: MockItem(id: duplicateID, title: "Duplicate"))
        }

        // Then
        let results: [MockItem] = try await sut.perform { try $0.fetchAll(MockItemCoreData.request()) }
        #expect(results.count == 2)
        #expect(results.map(\.title).contains("Original"))
        #expect(results.map(\.title).contains("Duplicate"))
    }

    @Test func performRead_emptyStore_returnsEmptyArray() async throws {
        // Given
        let sut = PersistencyService(provider: InMemoryPersistentContainer())

        // When
        let fetched: [MockItem] = try await sut.perform { try $0.fetchAll(MockItemCoreData.request()) }

        // Then
        #expect(fetched.isEmpty)
    }

    @Test func performRead_fetchOneRaw_missingObject_throws404() async throws {
        // Given
        let sut = PersistencyService(provider: InMemoryPersistentContainer())

        // When / Then
        do {
            let _: MockItemCoreData = try await sut.perform { try $0.fetchOneRaw(MockItemCoreData.request()) }

            #expect(Bool(false), "Expected fetchOneRaw to throw, but it succeeded")
        }
        catch let err as NSError {
            #expect(err.domain == "CoreDataFetchError")
            #expect(err.code == 404)
        }
    }

    @Test func performRemove_nonExistentObject_noCrash() async throws {
        // Given
        let sut = PersistencyService(provider: InMemoryPersistentContainer())

        try await sut.performCreate { $0.make(MockItemCoreData.self, from: MockItem(title: "Temp")) }

        // When
        try await sut.performRemove {
            if let toDelete = try? $0.fetchOneRaw(MockItemCoreData.request()) {
                // Delete the object
                $0.delete(toDelete)
            }
        }

        try await sut.performRemove {
            if let toDelete = try? $0.fetchOneRaw(MockItemCoreData.request()) {
                // Attempt to delete again – should not throw
                $0.delete(toDelete)
            }
        }

        // Then
        let results: [MockItem] = try await sut.perform { try $0.fetchAll(MockItemCoreData.request()) }
        #expect(results.isEmpty)
    }

    @Test func performCount_emptyStore_returnsZero() async throws {
        // Given
        let sut = PersistencyService(provider: InMemoryPersistentContainer())

        // When
        let count = try await sut.performCount { try $0.fetchCount(MockItemCoreData.request()) }

        // Then
        #expect(count == 0)
    }

    @Test func performCount_afterInserts_returnsCorrectNumber() async throws {
        // Given
        let sut = PersistencyService(provider: InMemoryPersistentContainer())

        try await sut.performCreate {
            for i in 0..<5 {
                $0.make(MockItemCoreData.self, from: MockItem(title: "Item \(i)"))
            }
        }

        // When
        let count = try await sut.performCount { try $0.fetchCount(MockItemCoreData.request()) }

        // Then
        #expect(count == 5)
    }

    @Test func performCreate_concurrentInserts_areAtomic() async throws {
        // Given
        let sut = PersistencyService(provider: InMemoryPersistentContainer())
        let ids = (0..<1000).map { _ in UUID() }

        // When
        await withThrowingTaskGroup(of: Void.self) { group in
            for id in ids {
                group.addTask {
                    try await sut.performCreate {
                        $0.make(MockItemCoreData.self, from: MockItem(id: id, title: "Item"))
                    }
                }
            }
        }

        // Then
        let count = try await sut.performCount { try $0.fetchCount(MockItemCoreData.request()) }
        #expect(count == ids.count)
    }

    @Test func performUpdateOrCreate_rollbackOnError() async throws {
        // Given
        let sut = PersistencyService(provider: InMemoryPersistentContainer())
        let item = MockItem(title: "Original")
        try await sut.performCreate { $0.make(MockItemCoreData.self, from: item) }

        // When
        do {
            try await sut.performUpdateOrCreate {
                let fetched: MockItemCoreData = try $0.fetchOneRaw(MockItemCoreData.request())
                fetched.title = "Modified"
                throw NSError(domain: "Test", code: 1, userInfo: nil)
            }
        }
        catch { }

        // Then
        let result: [MockItem] = try await sut.perform { try $0.fetchAll(MockItemCoreData.request()) }
        #expect(result.count == 1)
        #expect(result.first?.title == "Original")
    }

    @Test func performUpdateOrCreate_mergesWithoutDuplicate() async throws {
        // Given
        let sut = PersistencyService(provider: InMemoryPersistentContainer())
        let itemId = UUID()

        try await sut.performCreate {
            $0.make(MockItemCoreData.self, from: MockItem(id: itemId, title: "Original"))
        }

        // When
        try await sut.performUpdateOrCreate {
            let fetched: MockItemCoreData = try $0.fetchOneRaw(
                FetchRequestBuilder<MockItemCoreData>()
                    .setPredicates([Query(key: \.id, that: .equal(to: itemId))])
                    .build()
            )

            fetched.title = "Modified"
        }

        // Then
        let allItems: [MockItem] = try await sut.perform { try $0.fetchAll(MockItemCoreData.request()) }

        #expect(allItems.count == 1, "A duplicate row was created")
        #expect(allItems.first?.id == itemId, "The original object's id should be unchanged")
        #expect(allItems.first?.title == "Modified", "The title change was not persisted")
    }

    @Test func performCreate_and_performRead_parallel_tasks_produce_correct_finalCount() async throws {
        // GIVEN
        let sut = PersistencyService(provider: InMemoryPersistentContainer())
        let createTaskCount = 50

        // WHEN
        let insertedIDs: BoxActor<[UUID]> = .init([])
        let readResults: BoxActor<[[MockItem]]> = .init([[]])

        await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<createTaskCount {
                group.addTask {
                    let newID = UUID()

                    try await sut.performCreate {
                        $0.make(
                            MockItemCoreData.self,
                            from: MockItem(id: newID, title: "Item \(newID)")
                        )
                    }

                    var value = await insertedIDs.value
                    value.append(newID)
                    await insertedIDs.setValue(value)
                }
            }

            for _ in 0..<10 {
                group.addTask {
                    try await Task.sleep(nanoseconds: UInt64.random(in: 0..<200_000_000))

                    let snapshot: [MockItem] = try await sut.perform {
                        try $0.fetchAll(MockItemCoreData.request())
                    }

                    await readResults.setValue([snapshot])
                }
            }
        }

        // THEN
        let finalCount = try await sut.performCount { try $0.fetchCount(MockItemCoreData.request()) }
        let expectedCount = Set(await insertedIDs.value).count

        #expect(finalCount == expectedCount, "Final row count (\(finalCount)) does not equal number of successful inserts (\(expectedCount)).")

        for snapshot in await readResults.value {
            #expect(snapshot.count <= finalCount, "A read snapshot observed more rows than the final count.")
        }
    }
}
