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
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - View

extension TrackersView: View {
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                Group {
                    switch viewModel.state {
                    case .idle, .loading:
                        LoadingView()
                        
                    case .loaded(let models):
                        ScrollableLazyVStack(horizontalPadding: 0) {
                            ForEach(Array(models.enumerated()), id: \.element.id) { index, collection in
                                TrackersCollectionView(viewModel: collection)
                                    .padding(.horizontal, 12)
                                    .task { await viewModel.onSectionAppear(at: index) }
                            }
                            .id(topID)
                        }
                        
                    case .empty(let placeholder):
                        PlaceholderView(placeholder: placeholder)
                        
                    case .error:
                        ErrorView(onRetry: { })
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) { FilterMenuView(filter: $viewModel.filter) }
                    ToolbarItem(placement: .topBarTrailing) { DatePickerMenuView(date: $viewModel.currentDate) }
                }
                .safeAreaInset(edge: .bottom, alignment: .trailing) {
                    SafeAreaBottomView(
                        isToday: viewModel.isToday,
                        onCreate: viewModel.onAdd,
                        onToday: {
                            withAnimation { proxy.scrollTo(topID, anchor: .top) }
                            viewModel.onToday()
                        }
                    )
                }
            }
        }
        .searchable(text: $viewModel.queryString) { }
        .onAppear(perform: viewModel.onAppear)
    }
}

private struct DatePickerMenuView: View {
    @Binding var date: Date

    var body: some View {
        VStack {
            Text(date.formatted(.dateTime.day().month().year()))
                .padding()
        }
        .overlay {
            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
                .colorMultiply(.clear)
        }
    }
}

private struct FilterMenuView: View {
    @Binding var filter: TrackerFilter
    
    var body: some View {
        Menu {
            Picker("Filters", selection: $filter) {
                ForEach(TrackerFilter.allCases) { option in
                    Label(option.name, systemImage: option.systemImageName)
                        .tag(option)
                }
            }
            .backDeployedLabelsVisibility(.visible)
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
    }
}

private struct SafeAreaBottomView: View, KeyboardReadable {
    let isToday: Bool
    let onCreate: () -> Void
    let onToday: () -> Void
    
    @State private var isKeyboardShown = false
    
    var body: some View {
        HStack(spacing: 20) {
            if !isToday && !isKeyboardShown {
                Button(action: onToday) {
                    Text("Today")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                }
                .frame(height: 60)
                .background(.blue, in: .rect(cornerRadius: 12))
                .transition(.opacity)
            }
            
            Button(action: onCreate) {
                Image(systemName: "plus")
                    .resizable()
                    .symbolVariant(.circle.fill)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .blue)
            }
            .frame(width: 60, height: 60)
        }
        .animation(.easeIn, value: isToday)
        .padding(20)
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            isKeyboardShown = newIsKeyboardVisible
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
    
    func onAppear() { }
    func onSectionAppear(at index: Int) async { }
    func onToday() { }
    func onAdd() { }
}
#endif
