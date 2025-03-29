//
//  SectionsListView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 28.03.2025.
//

import SwiftUI
import Foundation
import TrackerDomain

struct SectionsListView<ViewModel: SectionsListViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - View

extension SectionsListView: View {
    var body: some View {
        switch viewModel.state {
        case .loading:
            ZStack {
                ProgressView()
            }
            
        case .loaded(let sections):
            NavigationStack {
                Group {
                    if sections.isEmpty {
                        PlaceholderSwiftUIView(placeholder: .emptySections)
                    }
                    else {
                        ScrollableLazyVStack {
                            VStack(spacing: 0) {
                                ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                                    ButtonView(
                                        title: section.title,
                                        isSelected: viewModel.selectedSection == section,
                                        onTap: { viewModel.onSection(section) }
                                    )
                                    
                                    if sections.count != index + 1 {
                                        Divider()
                                            .padding(.horizontal, 16)
                                    }
                                }
                            }
                            .background(.tertiary.opacity(0.3), in: .rect(cornerRadius: 16))
                            .padding(.top, 24)
                        }
                        .safeAreaInset(edge: .bottom, spacing: 16) {
                            Button(R.string.localizable.categoryAddNew(), action: { })
                                .buttonStyle(CommonButtonStyle(backgroundColor: .black))
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                        }
                    }
                }
                .navigationTitle(R.string.localizable.categoryCategory())
            }
            
        case .error:
            ErrorView(onRetry: { })
        }
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
                    .foregroundStyle(R.color.myBlack.color)
                    .layoutPriority(1)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(R.color.myBlue.color)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
    }
}

#if DEBUG
#Preview {
    SectionsListView(viewModel: ViewModel())
}

private final class ViewModel: SectionsListViewModelProtocol {
    let selectedSection: TrackerSection?
    let state: SectionsListState
    
    var route: SectionListRoute?
    
    init() {
        let section1: TrackerSection = .init(title: "asd", trackers: [])
        selectedSection = section1
        state = .loaded([
            section1,
            .init(title: "1asd", trackers: []),
        ])
    }
    
    func onSection(_ section: TrackerSection) { }
}
#endif
