//
//  StatisticViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.07.2024.
//

import Foundation

@MainActor
protocol StatisticViewModelProtocol: ObservableObject, Identifiable {
    var completedTrackersCount: Int { get }
    var title: String { get }
}

final class StatisticViewModel: StatisticViewModelProtocol {
    @Published private(set) var completedTrackersCount: Int
    @Published private(set) var title: String
    
    let id: UUID = .init()
    
    init(
        completedTrackersCount: Int = 0,
        title: String = R.string.localizable.statisticCompleted()
    ) {
        self.completedTrackersCount = completedTrackersCount
        self.title = title
    }
}
