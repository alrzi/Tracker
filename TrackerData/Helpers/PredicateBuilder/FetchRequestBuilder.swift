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
    
    func setPredicate(_ predicate: NSPredicate) -> FetchRequestBuilder {
        let newBuilder = self
        newBuilder.fetchRequest.predicate = predicate
        return newBuilder
    }
    
    func setSortDescriptors(_ sortDescriptors: [NSSortDescriptor]) -> FetchRequestBuilder {
        let newBuilder = self
        newBuilder.fetchRequest.sortDescriptors = sortDescriptors
        return newBuilder
    }
    
    func setFetchLimit(_ limit: Int) -> FetchRequestBuilder {
        let newBuilder = self
        newBuilder.fetchRequest.fetchLimit = limit
        return newBuilder
    }
    
    func setFetchOffset(_ offset: Int) -> FetchRequestBuilder {
        let newBuilder = self
        newBuilder.fetchRequest.fetchOffset = offset
        return newBuilder
    }
    
    func build() -> NSFetchRequest<T> {
        fetchRequest
    }
}
