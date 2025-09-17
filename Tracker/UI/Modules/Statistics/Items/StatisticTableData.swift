//
//  StatisticTableData.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.07.2024.
//

import Foundation

enum StatisticTableData {
    case bestPeriod(StatisticViewModel)
    case idealDays(StatisticViewModel)
    case completedTrackers(StatisticViewModel)
    case averageValue(StatisticViewModel)

    var title: String {
        switch self {
        case .bestPeriod: "Strings.Localizable.Statistic.bestPeriod"
        case .idealDays: "Strings.Localizable.Statistic.idealDays"
        case .completedTrackers: "Strings.Localizable.Statistic.completed"
        case .averageValue: "Strings.Localizable.Statistic.avarageValue"
        }
    }
    
    var viewModel: StatisticViewModel {
        switch self {
        case .bestPeriod(let viewModel): viewModel
        case .idealDays(let viewModel): viewModel
        case .completedTrackers(let viewModel): viewModel
        case .averageValue(let viewModel): viewModel
        }
    }
}

extension StatisticTableData: Identifiable {
    var id: UUID {
        switch self {
        case .bestPeriod(let viewModel): viewModel.id
        case .idealDays(let viewModel): viewModel.id
        case .completedTrackers(let viewModel): viewModel.id
        case .averageValue(let viewModel): viewModel.id
        }
    }
}
