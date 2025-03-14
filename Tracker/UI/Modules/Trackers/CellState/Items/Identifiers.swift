//
//  Identifiers.swift
//  Tracker
//
//  Created by Александр Зиновьев on 29.07.2024.
//

import Foundation

enum TrackersSectionID: Hashable {
    case sections(Int, UUID)
}

enum TrackersSectionItemID: Hashable {
    case tracker(UUID)
}
