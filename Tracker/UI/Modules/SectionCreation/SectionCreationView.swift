//
//  SectionCreationView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 02.04.2025.
//

import SwiftUI
import Foundation

@MainActor
struct SectionCreationView<ViewModel: SectionCreationViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel
    private let onClose: () -> Void
    
    init(
        viewModel: ViewModel,
        onClose: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onClose = onClose
    }
}

// MARK: - View

extension SectionCreationView: View {
    var body: some View {
        NavigationStack {
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
}

#if DEBUG
#Preview {
    SectionCreationView(viewModel: ViewModel(), onClose: { })
}

private final class ViewModel: SectionCreationViewModelProtocol {
    let invalidComponent: SectionCreationInvalidComponent? = nil
    
    var sectionTitle: String = ""
    
    func onPrimary() { }
}
#endif
