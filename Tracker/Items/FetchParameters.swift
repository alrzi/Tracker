//
//  FetchParameters.swift
//  Tracker
//
//  Created by Александр Зиновьев on 19.03.2025.
//

import Foundation

struct FetchParameters {
    private(set) var fetchLimit: Int
    private(set) var fetchOffset: Int
        
    mutating func nextPage() {
        fetchOffset += fetchLimit
    }
    
    mutating func reset() {
        fetchOffset = .zero
    }
}
