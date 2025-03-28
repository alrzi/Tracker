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
        ScrollableLazyVStack {
            VStack(spacing: 0) {
                ForEach(Array(tags.enumerated()), id: \.element.id) { index, tag in
                    Button(action: {
                        !selectedTags.contains(tag) ? selectedTags.append(tag) : selectedTags.removeAll { $0 == tag }
                    }) {
                        HStack {
                            Text(tag.localizedString().capitalized)
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Toggle("", isOn: Binding(
                                get: {
                                    selectedTags.contains(tag)
                                },
                                set: { newValue in
                                    if newValue {
                                        selectedTags.append(tag)
                                    }
                                    else {
                                        selectedTags.removeAll { $0 == tag }
                                    }
                                }
                            ))
                            .labelsHidden()
                            .tint(.green)
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
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
            Button(action: { onNext(selectedTags) }) {
                Text("Готово")
                    .foregroundStyle(.blue)
            }
        }
    }
}

#if DEBUG
#Preview {
    WeekDaysSelectionView { _ in }
}
#endif
