//
//  StatisticTableData.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.07.2024.
//

import Foundation

enum StatisticTableData {
    case bestPeriod(StatisticCellViewModel)
    case idealDays(StatisticCellViewModel)
    case completedTrackers(StatisticCellViewModel)
    case averageValue(StatisticCellViewModel)

    var title: String {
        switch self {
        case .bestPeriod: "Strings.Localizable.Statistic.bestPeriod"
        case .idealDays: "Strings.Localizable.Statistic.idealDays"
        case .completedTrackers: "Strings.Localizable.Statistic.completed"
        case .averageValue: "Strings.Localizable.Statistic.avarageValue"
        }
    }
    
    var viewModel: StatisticCellViewModel {
        switch self {
        case .bestPeriod(let viewModel): viewModel
        case .idealDays(let viewModel): viewModel
        case .completedTrackers(let viewModel): viewModel
        case .averageValue(let viewModel): viewModel
        }
    }
}
