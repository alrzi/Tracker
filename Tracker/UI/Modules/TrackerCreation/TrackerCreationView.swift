//
//  TrackerCreationView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import SwiftUI
import Foundation

@MainActor
struct TrackerCreationView<ViewModel: TrackerCreationViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel
    
    @Environment(\.dismiss)
    private var dismiss
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - View

extension TrackerCreationView: View {
    var body: some View {
        // swiftlint: disable next closure_body_length
        NavigationStack {
            ScrollableLazyVStack(spacing: 24) {
                TextField(R.string.localizable.createEnterName(), text: $viewModel.newTrackerText)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 27)
                    .background(.tertiary.opacity(0.3), in: .rect(cornerRadius: 16))
                    .padding(.top, 24)
                    .shake(if: viewModel.invalidComponent == .name)
                
                VStack(spacing: 0) {
                    ButtonView(
                        title: R.string.localizable.categoryCategory(),
                        subtitle: viewModel.sectionName,
                        onTap: viewModel.onSectionSelection
                    )
                    .shake(if: viewModel.invalidComponent == .section)
                    
                    Divider()
                        .padding(.horizontal, 16)
                    
                    ButtonView(
                        title: R.string.localizable.schedule(),
                        subtitle: viewModel.weekDaysFormatted,
                        onTap: viewModel.onWeekSelection
                    )
                    .shake(if: viewModel.invalidComponent == .weekDays)
                }
                .background(.tertiary.opacity(0.3), in: .rect(cornerRadius: 16))
                
                Section {
                    GridView(
                        viewModel: viewModel.emojiViewModel,
                        columns: 6,
                        spacing: 5,
                        content: { item, isSelected in
                            Text(item.value)
                                .padding(16)
                                .aspectRatio(1, contentMode: .fit)
                                .background(isSelected ? .gray.opacity(0.3) : Color.clear, in: RoundedRectangle(cornerRadius: 16))
                        }
                    )
                    .shake(if: viewModel.invalidComponent == .color)
                } header: {
                    HeaderView(text: R.string.localizable.createEmoji())
                }
                
                Section {
                    GridView(
                        viewModel: viewModel.colorsViewModel,
                        columns: 6,
                        spacing: 5,
                        content: { item, isSelected in
                            Color(hexString: item.value)
                                .aspectRatio(1, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(isSelected ? Color(hexString: item.value)?.opacity(0.4) ?? .blue : Color.clear, lineWidth: 4)
                                )
                        }
                    )
                    .shake(if: viewModel.invalidComponent == .emoji)
                } header: {
                    HeaderView(text: R.string.localizable.createColor())
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 16) {
                HStack {
                    Button(action: { dismiss() }) {
                        Text(R.string.localizable.createCancel())
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .foregroundStyle(.red)
                            .background(.clear, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.red, lineWidth: 1)
                            )
                    }
                    
                    Button(action: viewModel.onCreate) {
                        Text(R.string.localizable.createCreateNew())
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                            .padding(16)
                            .background(.secondary, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
                .background(Color(uiColor: .systemBackground))
            }
            .navigationTitle(R.string.localizable.createNewHabit())
        }
    }
}

private struct HeaderView: View {
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
                        .foregroundStyle(R.color.myBlack.color)
                       
                    if let subtitle {
                        Text(subtitle)
                            .lineLimit(1)
                            .foregroundStyle(.gray)
                    }
                }
                .layoutPriority(1)
                
                Spacer()
                
                Image(systemName: "chevron.forward")
                    .foregroundStyle(R.color.myGray.color)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
    }
}

#if DEBUG
#Preview {
    TrackerCreationView(viewModel: ViewModel())
}

private final class ViewModel: TrackerCreationViewModelProtocol {
    var route: TrackerCreationRoute?
    
    var newTrackerText: String = ""
    
    let sectionName: String? = "Sport"
    let weekDaysFormatted: String? = Date.now.formatted(.dateTime.weekday(.short))
    
    let emojiViewModel: GridViewModel<TrackerCreationGridItem> = .init(
        items: (0...17).map { _ in .init(value: RandomEmojiService.emoji) }
    )
    let colorsViewModel: GridViewModel<TrackerCreationGridItem> = .init(
        items: (0...17).map { _ in .init(value: RandomHexColorService.randomHexString) }
    )
    
    let invalidComponent: TrackerCreationInvalidComponent? = nil
       
    func onSectionSelection() { }
    func onWeekSelection() { }    
    func onCreate() { }
}
#endif
