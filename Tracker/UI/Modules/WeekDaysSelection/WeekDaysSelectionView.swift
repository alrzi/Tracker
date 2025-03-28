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
    let onNext: (WeekDays) -> Void
    
    private let tags = WeekDay.allCases()
    
    @State private var selectedTags: WeekDays = []
}

// MARK: - View

extension WeekDaysSelectionView: View {
    var body: some View {
        NavigationStack {
            ScrollableLazyVStack {
                VStack(spacing: 0) {
                    ForEach(Array(tags.enumerated()), id: \.element.id) { index, tag in
                        Button(action: {
                            !selectedTags.contains(tag) ? selectedTags.append(tag) : selectedTags.removeAll { $0 == tag }
                        }) {
                            ToggleView(
                                title: tag.localizedString().capitalized,
                                isSelected: selectedTags.contains(tag),
                                onToggle: { isSelected in
                                    if isSelected {
                                        selectedTags.append(tag)
                                    }
                                    else {
                                        selectedTags.removeAll { $0 == tag }
                                    }
                                }
                            )
                        }
                        
                        if tags.count != index + 1 {
                            Divider()
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .background(.tertiary.opacity(0.3), in: .rect(cornerRadius: 16))
                .padding(.top, 24)
            }
            .safeAreaInset(edge: .bottom) {
                Button("Готово", action: { onNext(selectedTags) })
                    .buttonStyle(
                        CommonButtonStyle(
                            backgroundColor: selectedTags.isEmpty ? .gray : .black
                        )
                    )
                    .padding(.horizontal, 16)
            }
            .navigationTitle("Выберите дни недели")
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
    WeekDaysSelectionView { _ in }
}
#endif
