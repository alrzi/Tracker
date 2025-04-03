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
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - View

extension StatisticsView: View {
    var body: some View {
        NavigationStack {
            ScrollableLazyVStack {
                VStack(spacing: 12) {
                    if viewModel.statisticData.isEmpty {
                        PlaceholderView(placeholder: .empty)
                    }
                    else {
                        ForEach(viewModel.statisticData) { data in
                            StatisticView(viewModel: data.viewModel)
                        }
                    }
                }
                .padding(.top, 24)
            }
            .onAppear(perform: viewModel.onAppear)
            .navigationTitle(R.string.localizable.statisticTitle())
        }
    }
}

#if DEBUG
#Preview {
    StatisticsView(viewModel: ViewModel())
}

private final class ViewModel: StatisticsViewModelProtocol {
    let statisticData: [StatisticTableData] = []
    
    func onAppear() { }
}
#endif
