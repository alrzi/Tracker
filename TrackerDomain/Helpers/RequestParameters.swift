//
//  RequestParameters.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 20.03.2025.
//

import Foundation

public struct RequestParameters {
    public let currentDate: Date
    public let weekDay: String
    public let query: String
    
    public let fetchLimit: Int
    public let fetchOffset: Int
   
    public init(
        currentDate: Date,
        weekDay: String,
        fetchLimit: Int,
        fetchOffset: Int,
        query: String
    ) {
        self.currentDate = currentDate
        self.weekDay = weekDay
        self.fetchLimit = fetchLimit
        self.fetchOffset = fetchOffset
        self.query = query
    }
}
