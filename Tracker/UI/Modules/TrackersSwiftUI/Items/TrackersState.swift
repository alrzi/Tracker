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
    case error
    
    var isLoaded: Bool {
        switch self {
        case .loading, .error, .idle: false
        case .loaded: true
        }
    }
    
    var isLoading: Bool {
        switch self {
        case .loading: true
        case .loaded, .error, .idle: false
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
        if case .loaded(let collection) = self {
            collection.count
        }
        else {
            0
        }
    }
}
