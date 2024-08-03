//
//  StatisticCellViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.07.2024.
//

import Foundation
import Combine

final class StatisticCellViewModel {
    @Published private(set) var completedTrackersCount: String

    init(completedTrackersCount: Int = 0) {
        self.completedTrackersCount = String(completedTrackersCount)
    }
}
