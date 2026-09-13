//
//  TrackersCollectionView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.03.2025.
//

import SwiftUI
import TrackerDomain

@MainActor
struct TrackersCollectionView<ViewModel: TrackersCollectionViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var columns: [GridItem] {
        return Array(
            repeating: GridItem(.flexible(), spacing: 5),
            count: columnCount
        )
    }

    private var columnCount: Int {
        let hasWideLayout = verticalSizeClass == .compact || horizontalSizeClass == .regular

        switch dynamicTypeSize {
        case .accessibility1, .accessibility2, .accessibility3:
            return hasWideLayout ? 2 : 1

        case .accessibility4, .accessibility5:
            return 1

        default:
            return hasWideLayout ? 3 : 2
        }
    }

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
                    .font(.headline)
                    .padding(.leading)
                    .padding(.bottom, 12)
                
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
                    .draggable(tracker.id.uuidString)
                }
            }
        }
        .dropDestination(for: String.self) { items, _ in
            guard viewModel.allowsTrackerDrop,
                  let trackerID = items.compactMap(UUID.init(uuidString:)).first
            else {
                return false
            }

            viewModel.onMove(trackerID: trackerID)
            return true
        }
        .alert(
            "Ошибка пометки трекера завершенным",
            isPresented: $viewModel.isCompletionConfirmationAlertPresented,
            presenting: viewModel.deleteTrackerConfirmationAlert,
            actions: { error in
                Button(error.confirmationButtonText) { }
            },
            message: { error in
                Text(error.message)
            }
        )
        .confirmationDialog(
            "Подтверждение удаления",
            isPresented: $viewModel.isDeleteTrackerConfirmationAlertPresented,
            presenting: viewModel.deleteTrackerConfirmationAlert,
            actions: { detail in
                Button(detail.cancelButtonText, role: .cancel) { }
                
                Button(detail.confirmationButtonText, role: .destructive) {
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
#Preview("Rich collection") {
    ScrollView {
        TrackersCollectionView(viewModel: CollectionViewModel())
            .padding(.horizontal, 12)
            .padding(.vertical)
    }
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Accessibility text") {
    ScrollView {
        TrackersCollectionView(viewModel: CollectionViewModel())
            .padding(.horizontal, 12)
            .padding(.vertical)
    }
    .background(Color(uiColor: .systemGroupedBackground))
    .environment(\.dynamicTypeSize, .accessibility3)
}

@MainActor
final class CollectionViewModel: TrackersCollectionViewModelProtocol {
    nonisolated let id: UUID = .init()
    let title = "Здоровье и развитие"
    let trackers: [Tracker]
    let allowsTrackerDrop = true
    let deleteTrackerConfirmationAlert: ErrorInfo? = nil
    
    var isDeleteTrackerConfirmationAlertPresented = false
    var isCompletionConfirmationAlertPresented = false

    init() {
        let sectionID = UUID()

        trackers = [
            Tracker(
                name: "Утренняя пробежка",
                emoji: "🏃‍♂️",
                color: "#FF6B6B",
                schedule: Set(WeekDay.allCases),
                isPinned: true,
                trackedDays: 28,
                sectionId: sectionID,
                isCompleted: true,
                notificationInformation: nil
            ),
            Tracker(
                name: "Выпить воду",
                emoji: "💧",
                color: "#3498DB",
                schedule: Set(WeekDay.allCases),
                trackedDays: 7,
                sectionId: sectionID,
                notificationInformation: nil
            ),
            Tracker(
                name: "Прочитать двадцать страниц профессиональной литературы",
                emoji: "📚",
                color: "#9B59B6",
                schedule: Set(WeekDay.allCases),
                trackedDays: 104,
                sectionId: sectionID,
                isCompleted: true,
                notificationInformation: nil
            ),
            Tracker(
                name: "Медитация",
                emoji: "🧘",
                color: "#2ECC71",
                schedule: Set(WeekDay.allCases),
                trackedDays: 0,
                sectionId: sectionID,
                notificationInformation: nil
            ),
            Tracker(
                name: "Английский",
                emoji: "🗣️",
                color: "#F5A623",
                schedule: Set(WeekDay.allCases),
                trackedDays: 365,
                sectionId: sectionID,
                notificationInformation: nil
            ),
            Tracker(
                name: "Сон до 23:00",
                emoji: "😴",
                color: "#34495E",
                schedule: Set(WeekDay.allCases),
                trackedDays: 12,
                sectionId: sectionID,
                notificationInformation: nil
            ),
        ]
    }
    
    func onToggleCompletion(at index: Int) { }
    func onTogglePin(at index: Int) { }
    func onEdit(at index: Int) { }
    func onDelete(at index: Int) { }
    func onMove(trackerID: UUID) { }
}
#endif
