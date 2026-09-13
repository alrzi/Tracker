//
//  TrackerFormView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import SwiftUI
import Foundation
import TrackerDomain

@MainActor
struct TrackerFormView<ViewModel: TrackerFormViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var gridColumnsCount: Int {
        switch dynamicTypeSize {
        case .accessibility3, .accessibility4, .accessibility5:
            return 3

        case .accessibility1, .accessibility2:
            return verticalSizeClass == .compact ? 5 : 4

        default:
            return verticalSizeClass == .compact ? 4 : 6
        }
    }
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - View

extension TrackerFormView: View {
    var body: some View {
        let usesTwoPaneLayout = verticalSizeClass == .compact && !dynamicTypeSize.isAccessibilitySize
        let layout = usesTwoPaneLayout
            ? AnyLayout(HStackLayout(alignment: .top, spacing: 24))
            : AnyLayout(VStackLayout(spacing: 24))

        NavigationStack {
            ScrollView {
                layout {
                    TrackerFormDetailsView(
                        title: $viewModel.tackerTitle,
                        sectionTitle: viewModel.sectionTitle,
                        invalidComponent: viewModel.invalidComponent,
                        habitScheduleViewModel: viewModel.habitScheduleViewModel,
                        onSectionSelection: viewModel.onSectionSelection
                    )
                    .frame(maxWidth: .infinity, alignment: .top)

                    TrackerFormAppearanceView(
                        emojiViewModel: viewModel.emojiViewModel,
                        colorsViewModel: viewModel.colorsViewModel,
                        columnsCount: gridColumnsCount,
                        invalidComponent: viewModel.invalidComponent
                    )
                    .frame(maxWidth: .infinity, alignment: .top)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationTitle(viewModel.title)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                    .accessibilityLabel(String(localized: .createCancel))

                    Spacer()

                    Button {
                        Task { await viewModel.onCompleteFrom() }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.headline)
                    }
                    .accessibilityLabel(viewModel.completeFormButtonTitle)
                }
            }
        }
    }
}

private struct TrackerFormDetailsView: View {
    @Binding var title: String

    let sectionTitle: String?
    let invalidComponent: TrackerFormInvalidComponent?
    let habitScheduleViewModel: TrackerFormHabitScheduleViewModel
    let onSectionSelection: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            TextFieldView(text: $title)
                .shake(if: invalidComponent == .title)

            VStack(spacing: 0) {
                ButtonView(
                    title: String(localized: .categoryCategory),
                    subtitle: sectionTitle,
                    onTap: onSectionSelection
                )
                .shake(if: invalidComponent == .section)

                Divider().padding(.horizontal, 16)

                TrackerFormHabitScheduleView(viewModel: habitScheduleViewModel)
                    .shake(if: invalidComponent == .weekDays)
            }
            .background(.tertiary.opacity(0.3), in: .rect(cornerRadius: 16))
        }
    }
}

private struct TrackerFormAppearanceView: View {
    let emojiViewModel: GridViewModel<TrackerFormGridItem>
    let colorsViewModel: GridViewModel<TrackerFormGridItem>
    let columnsCount: Int
    let invalidComponent: TrackerFormInvalidComponent?

    var body: some View {
        VStack(spacing: 24) {
            Section {
                GridView(
                    viewModel: emojiViewModel,
                    columns: columnsCount,
                    spacing: 5,
                    content: { item, isSelected in EmojiItemView(item: item.value, isSelected: isSelected) }
                )
                .shake(if: invalidComponent == .emoji)
            } header: {
                SectionHeaderView(text: String(localized: .createEmoji))
            }

            Section {
                GridView(
                    viewModel: colorsViewModel,
                    columns: columnsCount,
                    spacing: 5,
                    content: { item, isSelected in ColorItemView(item: item.value, isSelected: isSelected) }
                )
                .shake(if: invalidComponent == .color)
            } header: {
                SectionHeaderView(text: String(localized: .createColor))
            }
        }
    }
}

private struct EmojiItemView: View {
    let item: String
    let isSelected: Bool
    
    var body: some View {
        Text(item)
            .font(.title2)
            .padding(16)
            .aspectRatio(1, contentMode: .fit)
            .background(isSelected ? .gray.opacity(0.3) : Color.clear, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct ColorItemView: View {
    let item: String
    let isSelected: Bool
    
    var body: some View {
        Color(hexString: item)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color(hexString: item)?.opacity(0.4) ?? .blue : Color.clear, lineWidth: 4)
            )
    }
}

private struct TextFieldView: View {
    @Binding var text: String
    
    var body: some View {
        TextField(String(localized: .createEnterName), text: $text)
            .textContentType(.name)
            .keyboardType(.default)
            .foregroundStyle(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 27)
            .background(.tertiary.opacity(0.3), in: .rect(cornerRadius: 16))
            .padding(.top, 24)
    }
}

private struct SectionHeaderView: View {
    let text: String
    
    var body: some View {
        HStack {
            Text(text)
                .font(.headline)
                .layoutPriority(1)
            
            Spacer()
        }
        .padding(.horizontal, 8)
    }
}

private struct ButtonView: View {
    let title: String
    let subtitle: String?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundStyle(Color(.cBlack))
                    
                    if let subtitle {
                        Text(subtitle)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundStyle(.gray)
                    }
                }
                .layoutPriority(1)
                
                Spacer()
                
                Image(systemName: "chevron.forward")
                    .foregroundStyle(Color(.cGray))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
    }
}

private extension WeekDays {
    func formatted() -> String? {
        guard !self.isEmpty else {
            return nil
        }
        
        return self
            .sorted(by: { $0.sortOrder < $1.sortOrder })
            .compactMap { $0.abbreviationShort }
            .joined(separator: ", ")
    }
}

private extension WeekDay {
    var sortOrder: Int {
        Calendar.autoupdatingCurrent.firstWeekday == 1 ? sundaySortOrder : rawValue
    }
    
    var sundaySortOrder: Int {
        switch self {
        case .sunday: 0
        case .monday: 1
        case .tuesday: 2
        case .wednesday: 3
        case .thursday: 4
        case .friday: 5
        case .saturday: 6
        }
    }
}

#if DEBUG
#Preview("Portrait") {
    TrackerFormView(viewModel: ViewModel())
}

#Preview("Accessibility") {
    TrackerFormView(viewModel: ViewModel())
        .environment(\.dynamicTypeSize, .accessibility3)
}

private final class ViewModel: TrackerFormViewModelProtocol {
    var habitScheduleViewModel: TrackerFormHabitScheduleViewModel = .init(
        selectedDays: [.friday],
        info: .init(
            trackerId: .init(),
            isGlobalEnabled: true,
            schedule: [.friday: .init(weekDay: .friday, isEnabled: true, time: .now)]
        )
    )

    var route: TrackerFormRoute?
    
    var tackerTitle: String = "Утренняя тренировка"
    
    let title: String = "Новая привычка"
    let sectionTitle: String? = "Здоровье и развитие"
    let weekDays: WeekDays = []
    let completeFormButtonTitle = "Создать привычку"
    
    let emojiViewModel: GridViewModel<TrackerFormGridItem> = .init(
        items: TrackerFormGridOptions.emojiItems
    )
    let colorsViewModel: GridViewModel<TrackerFormGridItem> = .init(
        items: TrackerFormGridOptions.colorItems
    )
    
    let invalidComponent: TrackerFormInvalidComponent? = nil
    
    func onSectionSelection() { }
    func onWeekSelection() { }
    func onCompleteFrom() { }
}
#endif
