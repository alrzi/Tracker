//
//  TrackersState.swift
//  Tracker
//
//  Created by Александр Зиновьев on 18.03.2025.
//

import Foundation

enum TrackersState<Collection> {
    case idle
    case loading
    case loaded([Collection])
    case empty(Placeholder)
    case error
    
    var isLoading: Bool {
        switch self {
        case .loading: true
        case .loaded, .error, .idle, .empty: false
        }
    }
    
    var lastElementIndex: Int {
        if case .loaded(let collection) = self {
            return collection.count - 1
        }
        else {
            return 0
        }
    }
    
    var count: Int {
        models.count
    }
    
    var models: [Collection] {
        if case .loaded(let collection) = self {
            collection
        }
        else {
            []
        }
    }
}
