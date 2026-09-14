//
//  SectionCreationView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 02.04.2025.
//

import SwiftUI
import Foundation
import TrackerDomain

@MainActor
struct SectionCreationView<ViewModel: SectionCreationViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel
    private let onClose: () -> Void
    private let onCompleted: (TrackerSection) -> Void
    
    init(
        viewModel: ViewModel,
        onCompleted: @escaping (TrackerSection) -> Void,
        onClose: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onCompleted = onCompleted
        self.onClose = onClose
    }
}

// MARK: - View

extension SectionCreationView: View {
    var body: some View {
        ScrollableLazyVStack {
                TextField(String(localized: .createEnterName), text: $viewModel.sectionTitle)
                    .textContentType(.name)
                    .keyboardType(.default)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 27)
                    .background(.tertiary.opacity(0.3), in: .rect(cornerRadius: 16))
                    .padding(.top, 24)
                    .shake(if: viewModel.invalidComponent == .title)
                    .navigationTitle(String(localized: .categoryAddNew))
            }
            .safeAreaInset(edge: .bottom) {
            Button(String(localized: .scheduleReady), action: viewModel.onPrimary)
                    .buttonStyle(CommonButtonStyle(backgroundColor: .black))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
            .onChange(of: viewModel.completedSection) { _, section in
                guard let section else { return }
                onCompleted(section)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close")
                }
            }
    }
}

#if DEBUG
#Preview {
    SectionCreationView(viewModel: ViewModel(), onCompleted: { _ in }, onClose: { })
}

private final class ViewModel: SectionCreationViewModelProtocol {
    let invalidComponent: SectionCreationInvalidComponent? = nil
    let completedSection: TrackerSection? = nil
    
    var sectionTitle: String = ""
    
    func onPrimary() { }
}
#endif
