//
//  ComparisonType.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 14.03.2025.
//

import Foundation

enum ComparisonType {
    case equal
    case notEqual
    case greaterThan
    case lessThan
    case greaterThanOrEqual
    case lessThanOrEqual
    case like
    case beginsWith
    case endsWith
    case contains
    
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
        }
    }
}
