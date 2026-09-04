//
//  SwiftUIView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 02.04.2025.
//

import SwiftUI

@MainActor
struct StatisticView<ViewModel: StatisticViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - View

extension StatisticView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.count.formatted(.number))
                    .font(.largeTitle)
                
                Text(viewModel.title)
                    .font(.headline)
                
                Text(viewModel.subtitle)
                    .font(.subheadline)
            }
            .padding(16)
            .layoutPriority(1)
            
            Spacer(minLength: 0)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderAngularGradient, lineWidth: 1)
        )
    }
    
    private var borderAngularGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]),
            center: .center
        )
    }
}

#Preview {
    StatisticView(
        viewModel: StatisticViewModel(
            title: "Идеальные дни",
            subtitle: "Дни, когда были выполнены все запланированные привычки"
        )
    )
}
