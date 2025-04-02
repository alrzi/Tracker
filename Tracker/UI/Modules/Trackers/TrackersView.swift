//
//  TrackersView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.03.2025.
//

import SwiftUI
import Foundation
import TrackerDomain

@MainActor
struct TrackersView<ViewModel: TrackersViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel
    
    @Namespace private var topID
    @State private var keyboardShown = false
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - View

extension TrackersView: View, KeyboardReadable {
    var body: some View {
        // swiftlint:disable closure_body_length
        NavigationStack {
            ScrollViewReader { proxy in
                Group {
                    switch viewModel.state {
                    case .idle, .loading:
                        VStack {
                            Spacer()
                            Text("Loading")
                            Spacer()
                            HStack {
                                Spacer()
                            }
                        }
                        
                    case .loaded(let models):
                        ScrollableLazyVStack(horizontalPadding: 0) {
                            ForEach(Array(models.enumerated()), id: \.element.id) { index, collection in
                                TrackersCollectionView(viewModel: collection)
                                    .padding(.horizontal, 12)
                                    .onAppear { viewModel.onSectionAppear(at: index) }
                            }
                            .id(topID)
                        }
                        
                    case .empty(let placeholder):
                        PlaceholderView(placeholder: placeholder)
                        
                    case .error:
                        ErrorView(onRetry: { })
                    }
                }
                .safeAreaInset(edge: .bottom, alignment: .trailing) {
                    HStack(spacing: 20) {
                        if !viewModel.isToday && !keyboardShown {
                            Button(action: {
                                viewModel.onToday()
                                
                                withAnimation {
                                    proxy.scrollTo(topID, anchor: .top)
                                }
                            }) {
                                Text("Today")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 20)
                            }
                            .frame(height: 60)
                            .background(.blue, in: .rect(cornerRadius: 12))
                            .transition(.opacity)
                        }
                        
                        Button(action: viewModel.onAdd) {
                            Image(systemName: "plus")
                                .resizable()
                                .symbolVariant(.circle.fill)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, .blue)
                        }
                        .frame(width: 60, height: 60)
                    }
                    .animation(.easeIn, value: viewModel.isToday)
                    .padding(20)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        DatePicker("", selection: $viewModel.currentDate, displayedComponents: .date)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Picker(R.string.localizable.filtersTitle(), selection: $viewModel.filter) {
                                ForEach(TrackerFilter.allCases) { option in
                                    Label(option.name, systemImage: option.systemImageName)
                                        .tag(option)
                                }
                            }
                            .backDeployedLabelsVisibility(.visible)
                        }
                        label: {
                            Image(systemName: "line.3.horizontal.decrease")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .padding(16)
                                .background(Color.clear)
                                .contentShape(Rectangle())
                        }
                    }
                }
            }
        }
        .searchable(text: $viewModel.queryString) { }
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            keyboardShown = newIsKeyboardVisible
        }
    }
}

#if DEBUG
#Preview {
    TrackersView(viewModel: ViewModel())
}

private final class ViewModel: TrackersViewModelProtocol {
    var route: TrackersRoute?
    var filter: TrackerFilter = .completedForDate
    var queryString: String = ""
    var currentDate: Date = .now
    
    let isToday = false
    let state: TrackersState<CollectionViewModel> = .idle
    
    func onSectionAppear(at index: Int) { }
    func onToday() { }
    func onAdd() { }
}
#endif
