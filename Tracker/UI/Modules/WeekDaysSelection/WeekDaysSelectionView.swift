//
//  WeekDaysSelectionView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.03.2025.
//

import SwiftUI
import TrackerDomain
import Foundation

struct WeekDaysSelectionView {
    private let onNext: (WeekDays) -> Void
    private let weekDays: [WeekDay]
    
    @State private var selectedTags: WeekDays = []
    
    init(
        weekDays: [WeekDay],
        selectedTags: WeekDays,
        onNext: @escaping (WeekDays) -> Void
    ) {
        self.weekDays = weekDays
        self.selectedTags = selectedTags
        self.onNext = onNext
    }
}

// MARK: - View

extension WeekDaysSelectionView: View {
    var body: some View {
        NavigationStack {
            ScrollableLazyVStack {
                VStack(spacing: 0) {
                    ForEach(Array(weekDays.enumerated()), id: \.element.id) { index, weekDay in
                        ToggleView(
                            title: weekDay.abbreviationLong.capitalized,
                            isSelected: selectedTags.contains(weekDay),
                            onToggle: { isSelected in
                                if isSelected {
                                    selectedTags.insert(weekDay)
                                }
                                else {
                                    selectedTags.remove(weekDay)
                                }
                            }
                        )
                        
                        if weekDays.count != index + 1 {
                            Divider()
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .background(.tertiary.opacity(0.3), in: .rect(cornerRadius: 16))
                .padding(.top, 24)
            }
            .safeAreaInset(edge: .bottom, spacing: 16) {
                Button(R.string.localizable.scheduleReady(), action: { onNext(selectedTags) })
                    .buttonStyle(CommonButtonStyle(backgroundColor: .black))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
            .navigationTitle(R.string.localizable.schedule())
        }
    }
}

private struct ToggleView: View {
    let title: String
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.black)
                .layoutPriority(1)
            
            Spacer()
            
            Toggle("", isOn: .init(
                get: { isSelected },
                set: { newValue in
                    onToggle(newValue)
                }
            ))
            .labelsHidden()
            .tint(.blue)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
    }
}

#if DEBUG
#Preview {
    WeekDaysSelectionView(
        weekDays: WeekDay.allCases,
        selectedTags: [.friday],
        onNext: { _ in }
    )
}
#endif
