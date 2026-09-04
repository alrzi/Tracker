//
//  PredicateProviding.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 26.08.2025.
//

import Foundation

protocol PredicateProviding<Object> {
    associatedtype Object
    
    var predicate: NSPredicate { get }
}

struct Query<Object, Value>: PredicateProviding {
    let key: KeyPath<Object, Value>
    let that: Comparison<Value, Value>
    
    var predicate: NSPredicate {
        NSPredicate(
            format: String(that.format),
            argumentArray: [
                NSExpression(forKeyPath: key).keyPath,
                that.value.0,
                that.value.1.map({ $0 }) as Any,
            ]
        )
    }
}

struct SubQuery<Object, SubObject, Value>: PredicateProviding
where SubObject: Hashable {
    let key: KeyPath<Object, Set<SubObject>>
    let subKey: KeyPath<SubObject, Value>
    let that: Comparison<Value, Value>
    var isMore = true
    
    var predicate: NSPredicate {
        NSPredicate(
            format: String("SUBQUERY(%K, $g, $g.\(that.format)).@count \(isMore ? ">" : "==") 0"),
            argumentArray: [
                NSExpression(forKeyPath: key).keyPath,
                NSExpression(forKeyPath: subKey).keyPath,
                that.value.0,
                that.value.1.map({ $0 }) as Any,
            ]
        )
    }
}

struct SubSubQuery<Object, SubObject, SubSubObject, Value>: PredicateProviding
where SubObject: Hashable, SubSubObject: Hashable {
    let key: KeyPath<Object, Set<SubObject>>
    let subKey: KeyPath<SubObject, Set<SubSubObject>>
    let terKey: KeyPath<SubSubObject, Value>
    let that: Comparison<Value, Value>
    let isMore: Bool
    
    var predicate: NSPredicate {
        NSPredicate(
            format: String("SUBQUERY(%K, $g, SUBQUERY($g.%K, $h, $h.\(that.format))\(isMore ? ".@count > 0" : ".@count == 0")).@count > 0"),
            argumentArray: [
                NSExpression(forKeyPath: key).keyPath,
                NSExpression(forKeyPath: subKey).keyPath,
                NSExpression(forKeyPath: terKey).keyPath,
                that.value.0,
                that.value.1.map({ $0 }) as Any,
            ]
        )
    }
}

enum Comparison<T, V> {
    case equal(to: T)
    case notEqual(to: T)
    case greaterThan(T)
    case lessThan(T)
    case greaterThanOrEqual(then: T)
    case lessThanOrEqual(then: T)
    case like(T)
    case beginsWith(T)
    case endsWith(T)
    case contains(T)
    case between(T, V)
    
    var value: (T, V?) {
        switch self {
        case .equal(let value): (value, nil)
        case .notEqual(let value): (value, nil)
        case .greaterThan(let value): (value, nil)
        case .lessThan(let value): (value, nil)
        case .greaterThanOrEqual(let value): (value, nil)
        case .lessThanOrEqual(let value): (value, nil)
        case .like(let value): (value, nil)
        case .beginsWith(let value): (value, nil)
        case .endsWith(let value): (value, nil)
        case .contains(let value): (value, nil)
        case .between(let value, let another): (value, another)
        }
    }
    
    var format: String {
        switch self {
        case .equal: "%K == %@"
        case .notEqual: "%K != %@"
        case .greaterThan: "%K > %@"
        case .lessThan: "%K < %@"
        case .greaterThanOrEqual: "%K >= %@"
        case .lessThanOrEqual: "%K <= %@"
        case .like: "%K LIKE %@"
        case .beginsWith: "%K BEGINSWITH %@"
        case .endsWith: "%K ENDSWITH %@"
        case .contains: "%K CONTAINS[cd] %@"
        case .between: "%K BETWEEN {%@, %@}"
        }
    }
}
