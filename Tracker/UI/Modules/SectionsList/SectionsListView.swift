//
//  SectionsListView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 28.03.2025.
//

import SwiftUI
import Foundation
import TrackerDomain

@MainActor
struct SectionsListView<ViewModel: SectionsListViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel
    private let onClose: () -> Void
    private let onCreate: () -> Void
    private let onUpdate: (TrackerSection) -> Void
    private let onSelected: (TrackerSection) -> Void
    
    init(
        viewModel: ViewModel,
        onCreate: @escaping () -> Void,
        onUpdate: @escaping (TrackerSection) -> Void,
        onSelected: @escaping (TrackerSection) -> Void,
        onClose: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onCreate = onCreate
        self.onUpdate = onUpdate
        self.onSelected = onSelected
        self.onClose = onClose
    }
}

// MARK: - View

extension SectionsListView: View {
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ZStack {
                    ProgressView()
                }

            case .loaded(let sections):
                Group {
                    if sections.isEmpty {
                        PlaceholderView(placeholder: .emptySections)
                    }
                    else {
                        ScrollableLazyVStack {
                            VStack(spacing: 0) {
                                ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                                    ButtonView(
                                        title: section.title,
                                        isSelected: viewModel.selectedSection?.id == section.id,
                                        onTap: {
                                            viewModel.onSection(section)
                                            onSelected(section)
                                        }
                                    )
                                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16))
                                    .contextMenu {
                                        Section("Modifications") {
                                            Button(action: { onUpdate(section) }) {
                                                Label(String(localized: .contextUpdate), systemImage: "repeat.circle")
                                            }
                                        }
                                        
                                        Divider()
                                        
                                        Button(role: .destructive, action: { viewModel.onSectionDelete(section) }) {
                                            Label(String(localized: .contextDelete), systemImage: "xmark.bin")
                                        }
                                    }
                                    
                                    if sections.count != index + 1 {
                                        Divider()
                                            .padding(.horizontal, 16)
                                    }
                                }
                            }
                            .background(.tertiary.opacity(0.3), in: .rect(cornerRadius: 16))
                            .padding(.top, 24)
                        }
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 16) {
                    Button(String(localized: .categoryAddNew), action: onCreate)
                        .buttonStyle(CommonButtonStyle(backgroundColor: .black))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                }
                .navigationTitle(String(localized: .categoryCategory))
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                        }
                        .accessibilityLabel("Close")
                    }
                }

            case .error:
                ErrorView(onRetry: viewModel.onAppear)
            }
        }
        .onAppear(perform: viewModel.onAppear)
    }
}

private struct ButtonView: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .foregroundStyle(Color(.cBlack))
                    .layoutPriority(1)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color(.cBlue))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
    }
}

#if DEBUG
#Preview {
    SectionsListView(
        viewModel: ViewModel(),
        onCreate: { },
        onUpdate: { _ in },
        onSelected: { _ in },
        onClose: { }
    )
}

private final class ViewModel: SectionsListViewModelProtocol {
    let selectedSection: TrackerSection?
    let state: SectionsListState
    
    init() {
        let section1: TrackerSection = .init(title: "asd", trackers: [])
        selectedSection = section1
        state = .loaded([
            section1,
            .init(title: "1asd", trackers: []),
        ])
    }
    
    func onSection(_ section: TrackerSection) { }
    func onSectionDelete(_ section: TrackerSection) { }
    func onAppear() { }
}
#endif
