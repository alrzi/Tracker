//
//  TrackersCollectionView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.03.2025.
//

import SwiftUI
import TrackerDomain

struct TrackersCollectionView<ViewModel: TrackersCollectionViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel
    
    private let columns = [
        GridItem(.adaptive(minimum: 170, maximum: 220), spacing: 5),
        GridItem(.adaptive(minimum: 170, maximum: 220), spacing: 5)
    ]
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - View

extension TrackersCollectionView: View {
    var body: some View {
        LazyVStack {
            HStack {
                Text(viewModel.title)
                    .font(.system(size: 19, weight: .bold))
                    .padding(.leading)
                
                Spacer()
            }
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(viewModel.trackers.enumerated()), id: \.element.id) { index, tracker in
                    TrackerItemView(
                        tracker: tracker,
                        onToggleCompletion: { viewModel.onToggleCompletion(at: index) },
                        onTogglePin: { viewModel.onTogglePin(at: index) },
                        onEdit: { viewModel.onEdit(at: index) },
                        onDelete: { viewModel.onDelete(at: index) }
                    )
                }
            }
        }
        .confirmationDialog(
            "Уверены что хотите удалить?",
            isPresented: $viewModel.isDeleteTrackerConfirmationAlertPresented,
            presenting: viewModel.deleteTrackerConfirmationAlert,
            actions: { detail in
                Button("Cancel", role: .cancel) { }
                
                Button("Delete", role: .destructive) {
                    detail.onConfirm()
                }
            },
            message: { detail in
                Text(detail.message)
            }
        )
    }
}

#if DEBUG
#Preview {
    TrackersCollectionView(viewModel: CollectionViewModel())
}

final class CollectionViewModel: TrackersCollectionViewModelProtocol {
    let id: UUID = .init()
    let title: String = "Pinned"
    let trackers: [Tracker] = []
    let deleteTrackerConfirmationAlert: ErrorInfo? = nil
    
    var isDeleteTrackerConfirmationAlertPresented = false
    
    func onToggleCompletion(at index: Int) { }
    func onTogglePin(at index: Int) { }
    func onEdit(at index: Int) { }
    func onDelete(at index: Int) { }
}
#endif
