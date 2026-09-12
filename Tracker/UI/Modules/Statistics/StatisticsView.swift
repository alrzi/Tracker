//
//  StatisticsView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 02.04.2025.
//

import SwiftUI
import Foundation

@MainActor
struct StatisticsView<ViewModel: StatisticsViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var columns: [GridItem] {
        return Array(
            repeating: GridItem(.flexible(), alignment: .top),
            count: columnCount
        )
    }

    private var columnCount: Int {
        let hasWideLayout = verticalSizeClass == .compact || horizontalSizeClass == .regular

        switch dynamicTypeSize {
        case .accessibility1, .accessibility2:
            return hasWideLayout ? 2 : 1

        case .accessibility3, .accessibility4, .accessibility5:
            return 1

        default:
            return hasWideLayout ? 2 : 1
        }
    }
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - View

extension StatisticsView: View {
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.statisticData.isEmpty {
                    PlaceholderView(placeholder: .emptyStatistic)
                }
                else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(viewModel.statisticData) { data in
                                StatisticView(viewModel: data.viewModel)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                }
            }
            .navigationTitle(String(localized: .statisticTitle))
        }
        .onAppear(perform: viewModel.onAppear)
    }
}

#if DEBUG
#Preview("Portrait") {
    StatisticsView(viewModel: ViewModel())
}

#Preview("Accessibility") {
    StatisticsView(viewModel: ViewModel())
        .environment(\.dynamicTypeSize, .accessibility3)
}

private final class ViewModel: StatisticsViewModelProtocol {
    let statisticData: [StatisticTableData] = [
        .bestPeriod(.init(count: 18, title: "Лучший период", subtitle: "Максимальное количество дней без перерыва")),
        .idealDays(.init(count: 7, title: "Идеальные дни", subtitle: "Дни, когда были выполнены все запланированные привычки")),
        .completedTrackers(.init(count: 128, title: "Трекеры завершены", subtitle: "Общее количество выполненных трекеров")),
        .averageValue(.init(count: 4, title: "Среднее значение", subtitle: "Среднее количество выполненных трекеров в день")),
    ]
    
    func onAppear() { }
}
#endif
