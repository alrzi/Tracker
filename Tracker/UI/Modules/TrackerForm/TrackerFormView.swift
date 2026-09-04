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
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - View

extension TrackerFormView: View {
    var body: some View {
        NavigationStack {
            ScrollableLazyVStack(spacing: 24) {
                TextFieldView(text: $viewModel.tackerTitle)
                    .shake(if: viewModel.invalidComponent == .title)
                
                VStack(spacing: 0) {
                    ButtonView(
                        title: String(localized: .categoryCategory),
                        subtitle: viewModel.sectionTitle,
                        onTap: viewModel.onSectionSelection
                    )
                    .shake(if: viewModel.invalidComponent == .section)
                    
                    Divider().padding(.horizontal, 16)
                    
                    TrackerFormHabitScheduleView(viewModel: viewModel.habitScheduleViewModel)
                        .shake(if: viewModel.invalidComponent == .weekDays)
                }
                .background(.tertiary.opacity(0.3), in: .rect(cornerRadius: 16))
                
                Section {
                    GridView(
                        viewModel: viewModel.emojiViewModel,
                        columns: 6,
                        spacing: 5,
                        content: { item, isSelected in EmojiItemView(item: item.value, isSelected: isSelected) }
                    )
                    .shake(if: viewModel.invalidComponent == .emoji)
                } header: { SectionHeaderView(text: String(localized: .createEmoji)) }
                
                Section {
                    GridView(
                        viewModel: viewModel.colorsViewModel,
                        columns: 6,
                        spacing: 5,
                        content: { item, isSelected in ColorItemView(item: item.value, isSelected: isSelected) }
                    )
                    .shake(if: viewModel.invalidComponent == .color)
                } header: { SectionHeaderView(text: String(localized: .createColor)) }
            }
            .safeAreaInset(edge: .bottom, spacing: 16) {
                MainFooterView(
                    title: viewModel.completeFormButtonTitle,
                    onCompleteFrom: viewModel.onCompleteFrom
                )
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationTitle(viewModel.title)
        }
    }
}

private struct EmojiItemView: View {
    let item: String
    let isSelected: Bool
    
    var body: some View {
        Text(item)
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
            .padding(4)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color(hexString: item)?.opacity(0.4) ?? .blue : Color.clear, lineWidth: 4)
            )
    }
}

private struct MainFooterView: View {
    @Environment(\.dismiss)
    private var dismiss
    
    let title: String
    let onCompleteFrom: () async -> Void
    
    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                Text(String(localized: .createCancel))
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .foregroundStyle(.red)
                    .background(.clear, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.red, lineWidth: 1)
                    )
            }
            
            Button(action: { Task { await onCompleteFrom() } }) {
                Text(title)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color(.cBlack))
                    .padding(16)
                    .background(.secondary, in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color(uiColor: .systemBackground))
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
                .font(.system(size: 19, weight: .bold))
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
                            .lineLimit(1)
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
#Preview {
    TrackerFormView(viewModel: ViewModel())
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
    
    var tackerTitle: String = ""
    
    let title: String = ""
    let sectionTitle: String? = "Sport"
    let weekDays: WeekDays = []
    let completeFormButtonTitle = "Create"
    
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
