//
//  TrackerFormGridItem.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import Foundation

struct TrackerFormGridItem: Identifiable, Hashable, Equatable {
    let id: UUID = .init()
    let value: String
}
