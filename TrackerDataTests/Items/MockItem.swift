//
//  MockItem.swift
//  TrackerDataTests
//
//  Created by Александр Зиновьев on 20.11.2025.
//

import Foundation
import CoreData
@testable import TrackerData

public struct MockItem: Sendable, Identifiable {
    public let id: UUID
    public let title: String
}

@objc(MockItemCoreData)
public class MockItemCoreData: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String

    static func request() -> NSFetchRequest<MockItemCoreData> {
        NSFetchRequest<MockItemCoreData>(entityName: String(describing: MockItemCoreData.self))
    }
}

extension MockItemCoreData: Entity { }

extension MockItemCoreData: CopyableEntity {
    public func copy(from item: MockItem) {
        self.id = item.id
        self.title = item.title
    }
}

extension MockItem: Initable {
    public init(object: MockItemCoreData) {
        self.init(
            id: object.id,
            title: object.title
        )
    }
}
