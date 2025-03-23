//
//  TrackerCreationSwiftUIView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import SwiftUI
import Foundation

@MainActor
struct TrackerCreationSwiftUIView<ViewModel: TrackerCreationSwiftUIViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel
    
    private let columns = [
        GridItem(.flexible(), spacing: 5),
        GridItem(.flexible(), spacing: 5),
        GridItem(.flexible(), spacing: 5),
        GridItem(.flexible(), spacing: 5),
        GridItem(.flexible(), spacing: 5),
        GridItem(.flexible(), spacing: 5),
    ]
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - View

extension TrackerCreationSwiftUIView: View {
    var body: some View {
        // swiftlint: disable next closure_body_length
        NavigationStack {
            ScrollableLazyVStack(spacing: 24) {
                TextField(R.string.localizable.createEnterName(), text: $viewModel.newTrackerText)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 27)
                    .background(.tertiary, in: .rect(cornerRadius: 16))
                    .padding(.top, 24)
                
                VStack(spacing: 0) {
                    ButtonView(
                        text: R.string.localizable.categoryCategory(),
                        onTap: { }
                    )
                    
                    Divider()
                        .padding(.horizontal, 16)
                    
                    ButtonView(
                        text: R.string.localizable.schedule(),
                        onTap: { }
                    )
                }
                .background(.tertiary, in: .rect(cornerRadius: 16))
                
                Section {
                    GridView(
                        viewModel: viewModel.emojiViewModel,
                        columns: 6,
                        spacing: 5,
                        content: { item, isSelected in
                            Text(item.value)
                                .padding(16)
                                .aspectRatio(1, contentMode: .fit)
                                .background(isSelected ? Color.gray.opacity(0.3) : Color.clear, in: RoundedRectangle(cornerRadius: 16))
                        }
                    )
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
                } header: {
                    HeaderView(text: R.string.localizable.createColor())
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 16) {
                HStack {
                    Button(action: { }) {
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
                    
                    Button(action: { }) {
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
    let text: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(text)
                    .foregroundStyle(R.color.myBlack.color)
                    .layoutPriority(1)
                
                Spacer()
                
                Image(systemName: "chevron.forward")
                    .foregroundStyle(R.color.myGray.color)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 27)
        }
    }
}

#if DEBUG
#Preview {
    TrackerCreationSwiftUIView(viewModel: ViewModel())
}

private final class ViewModel: TrackerCreationSwiftUIViewModelProtocol {
    let emojiViewModel: GridViewModel<TrackerCreationSwiftUIGridItem> = .init(
        items: (0...17).map { _ in .init(value: RandomEmojiService.emoji) }
    )
    let colorsViewModel: GridViewModel<TrackerCreationSwiftUIGridItem> = .init(
        items: (0...17).map { _ in .init(value: RandomHexColorService.randomHexString) }
    )
    
    var newTrackerText: String = ""
}
#endif
