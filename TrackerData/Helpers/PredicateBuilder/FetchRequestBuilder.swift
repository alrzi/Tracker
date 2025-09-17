//
//  FetchRequestBuilder.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 12.03.2025.
//

import Foundation
import CoreData

struct FetchRequestBuilder<T: NSManagedObject & Entity> {
    private var fetchRequest: NSFetchRequest<T>
    
    init() {
        self.fetchRequest = NSFetchRequest<T>(entityName: T.entityName)
    }
    
    func setPredicates(_ predicates: [any PredicateProviding<T>]) -> Self {
        let newBuilder = self
        newBuilder.fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: predicates.map({ $0.predicate }))
        return newBuilder
    }
    
    func setSortDescriptors<V>(_ sortDescriptors: [SortDescriptor<V>]) -> Self {
        let newBuilder = self
        newBuilder.fetchRequest.sortDescriptors = sortDescriptors.map { .init(keyPath: $0.keyPath, ascending: $0.ascending) }
        return newBuilder
    }
    
    func setFetchLimit(_ limit: Int) -> Self {
        let newBuilder = self
        newBuilder.fetchRequest.fetchLimit = limit
        return newBuilder
    }
    
    func setFetchOffset(_ offset: Int) -> Self {
        let newBuilder = self
        newBuilder.fetchRequest.fetchOffset = offset
        return newBuilder
    }
    
    func build() -> NSFetchRequest<T> {
        fetchRequest
    }
}

extension FetchRequestBuilder {
    struct SortDescriptor<Value> {
        let keyPath: KeyPath<T, Value>
        var ascending = true
    }
}
