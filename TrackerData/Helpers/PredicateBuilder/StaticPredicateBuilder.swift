//
//  StaticPredicateBuilder.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 12.03.2025.
//

import Foundation

struct StaticPredicateBuilder<T> {
    private var predicates: [NSPredicate] = []
    
    func filter<V>(by keyPath: KeyPath<T, V>, value: V, comparison: ComparisonType) -> StaticPredicateBuilder {
        let key = NSExpression(forKeyPath: keyPath).keyPath
        let predicate = NSPredicate(format: comparison.format, argumentArray: [key, value])
        
        var builder = self
        builder.predicates.append(predicate)
        
        return builder
    }
    
    func subpredicate<M, V>(
        by keyPath: KeyPath<T, Set<M>>,
        subKeyPath: KeyPath<M, V>,
        subValue: V,
        comparison: ComparisonType,
        isMore: Bool = true
    ) -> StaticPredicateBuilder {
        let key = NSExpression(forKeyPath: keyPath).keyPath
        let subKey = NSExpression(forKeyPath: subKeyPath).keyPath
        let formatString = "SUBQUERY(%K, $g, $g.\(comparison.format)).@count \(isMore ? ">" : "==") 0"
        let predicate = NSPredicate(format: formatString, argumentArray: [key, subKey, subValue])
        
        var builder = self
        builder.predicates.append(predicate)
        
        return builder
    }
    
    func subpredicateBetween<M, V>(
        by keyPath: KeyPath<T, Set<M>>,
        subKeyPath: KeyPath<M, V>,
        subValue1: V,
        subValue2: V
    ) -> StaticPredicateBuilder {
        let key = NSExpression(forKeyPath: keyPath).keyPath
        let subKey = NSExpression(forKeyPath: subKeyPath).keyPath
        let formatString = "SUBQUERY(%K, $g, $g.%K BETWEEN {%@, %@}).@count == 0"
        let predicate = NSPredicate(format: formatString, argumentArray: [key, subKey, subValue1, subValue2])
        
        var builder = self
        builder.predicates.append(predicate)
        
        return builder
    }
    
    func subpredicateInSubpredicate<M, V, D>(
        by keyPath: KeyPath<T, Set<M>>,
        subKeyPath: KeyPath<M, Set<V>>,
        terKeyPath: KeyPath<V, D>,
        subValue1: D,
        subValue2: D,
        isMore: Bool = true
    ) -> StaticPredicateBuilder {
        let key = NSExpression(forKeyPath: keyPath).keyPath
        let subKey = NSExpression(forKeyPath: subKeyPath).keyPath
        let terKey = NSExpression(forKeyPath: terKeyPath).keyPath
        
        let formatString = "SUBQUERY(%K, $g, SUBQUERY($g.%K, $h, $h.%K BETWEEN {%@, %@}).@count > 0).@count > 0"
        let predicate = NSPredicate(format: formatString, argumentArray: [key, subKey, terKey, subValue1, subValue2])
        
        var builder = self
        builder.predicates.append(predicate)
        
        return builder
    }
    
    func combine(with type: NSCompoundPredicate.LogicalType) -> NSPredicate {
        NSCompoundPredicate(type: type, subpredicates: predicates)
    }
    
    func build() -> NSPredicate {
        predicates.isEmpty ? NSPredicate(value: true) : combine(with: .and)
    }
}
