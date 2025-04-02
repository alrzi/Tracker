//
//  SwiftUIView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 02.04.2025.
//

import SwiftUI

struct StatisticView<ViewModel: StatisticViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - View

extension StatisticView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                Color.green,
                                Color.red,
                                Color.blue
                            ]
                        ),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 90)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 2)
                )
            
            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.completedTrackersCount.formatted(.number))
                        .font(.largeTitle)
                        .padding(.top, 12)
                        .padding(.leading, 12)
                    
                    Spacer()
                    
                    Text(viewModel.title)
                        .font(.subheadline)
                        .padding(.leading, 12)
                        .padding(.bottom, 12)
                }
                .padding(.top, 12)
                .layoutPriority(1)
                
                Spacer()
            }
        }
        .padding(.horizontal, 6)
    }
}

#Preview {
    StatisticView(viewModel: StatisticViewModel())
}
