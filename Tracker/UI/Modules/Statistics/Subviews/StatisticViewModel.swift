//
//  StatisticViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.07.2024.
//

import Foundation

@MainActor
protocol StatisticViewModelProtocol: ObservableObject, Identifiable {
    var count: Int { get }
    var title: String { get }
    var subtitle: String { get  }
}

final class StatisticViewModel: StatisticViewModelProtocol {
    @Published private(set) var count: Int
    @Published private(set) var title: String
    @Published private(set) var subtitle: String
    
    let id: UUID = .init()
    
    init(
        count: Int = 0,
        title: String,
        subtitle: String
    ) {
        self.count = count
        self.title = title
        self.subtitle = subtitle
    }
}
