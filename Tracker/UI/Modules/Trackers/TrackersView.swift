//
//  TrackersView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.03.2025.
//

import SwiftUI
import Foundation
import Combine
import TrackerDomain

@MainActor
struct TrackersView<ViewModel: TrackersViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel
    private let onCreate: () -> Void
    private let onEdit: (Tracker) -> Void
    
    @Namespace private var topID
    @GestureState private var swipeTranslation: CGSize = .zero
    
    init(
        viewModel: ViewModel,
        onCreate: @escaping () -> Void,
        onEdit: @escaping (Tracker) -> Void
    ) {
        self.viewModel = viewModel
        self.onCreate = onCreate
        self.onEdit = onEdit
    }
}

// MARK: - View

extension TrackersView: View {
    var body: some View {
        ScrollViewReader { proxy in
                Group {
                    switch viewModel.state {
                    case .idle, .loading:
                        LoadingView()
                        
                    case .loaded(let models):
                        ScrollableLazyVStack(horizontalPadding: 0) {
                            ForEach(Array(models.enumerated()), id: \.element.id) { index, collection in
                                TrackersCollectionView(
                                    viewModel: collection,
                                    onEvent: viewModel.handleCollectionEvent
                                )
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
                        onCreate: {
                            viewModel.onAdd()
                            onCreate()
                        },
                        onToday: {
                            withAnimation { proxy.scrollTo(topID, anchor: .top) }
                            viewModel.onToday()
                        }
                    )
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 30)
                        .updating($swipeTranslation) { value, translation, _ in
                            translation = value.translation
                        }
                        .onEnded { value in
                            let translation = value.translation

                            guard abs(translation.width) > 70,
                                  abs(translation.width) > abs(translation.height) * 1.25
                            else {
                                return
                            }

                            viewModel.onDaySwipe(translation.width < 0 ? .next : .previous)
                        }
                )
        }
        .searchable(text: $viewModel.queryString) { }
        .overlay {
            EdgeSwipeHints(translation: swipeTranslation)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
        }
        .onAppear(perform: viewModel.onAppear)
        .onReceive(viewModel.createRequests) { onCreate() }
        .onReceive(viewModel.editRequests, perform: onEdit)
    }
}

private struct EdgeSwipeHints: View {
    let translation: CGSize

    var body: some View {
        let isHorizontal = abs(translation.width) > abs(translation.height) * 1.25
        let progress = isHorizontal ? min(abs(translation.width) / 70, 1) : 0
        let leadingProgress = translation.width > 0 ? progress : 0
        let trailingProgress = translation.width < 0 ? progress : 0

        ZStack {
            EdgeArcShape(
                edge: .leading,
                progress: leadingProgress
            )
            .fill(Color.accentColor.opacity(0.4))
            .opacity(leadingProgress * 0.8)

            EdgeArcShape(
                edge: .trailing,
                progress: trailingProgress
            )
            .fill(Color.accentColor.opacity(0.4))
            .opacity(trailingProgress * 0.8)
        }
    }
}

private struct EdgeArcShape: Shape {
    enum Edge {
        case leading
        case trailing
    }

    let edge: Edge
    let progress: CGFloat

    func path(in rect: CGRect) -> Path {
        let halfHeight = rect.height * 0.045
        let maximumDepth = min(rect.width * 0.035, halfHeight * 0.4)
        let depth = maximumDepth * progress
        let edgeX = edge == .leading ? rect.minX : rect.maxX
        let tipX = edge == .leading ? edgeX + depth : edgeX - depth

        var path = Path()
        path.move(to: CGPoint(x: edgeX, y: rect.midY - halfHeight))
        path.addQuadCurve(
            to: CGPoint(x: edgeX, y: rect.midY + halfHeight),
            control: CGPoint(x: tipX, y: rect.midY)
        )
        path.addLine(to: CGPoint(x: edgeX, y: rect.midY - halfHeight))
        path.closeSubpath()
        return path
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
                .font(.title3)
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
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                }
                .background(.blue, in: .rect(cornerRadius: 12))
                .transition(.opacity)
            }
            
            Button(action: onCreate) {
                Image(systemName: "plus")
                    .font(.largeTitle)
                    .imageScale(.large)
                    .symbolVariant(.circle.fill)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .blue)
            }
            .padding(16)
            .contentShape(.circle)
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
    TrackersView(viewModel: ViewModel(), onCreate: { }, onEdit: { _ in })
}

private final class ViewModel: TrackersViewModelProtocol {
    var filter: TrackerFilter = .completedForDate
    var queryString: String = ""
    var currentDate: Date = .now
    
    let isToday = false
    let state: TrackersState<CollectionViewModel> = .idle
    let createRequests = Empty<Void, Never>().eraseToAnyPublisher()
    let editRequests = Empty<Tracker, Never>().eraseToAnyPublisher()
    
    func onAppear() { }
    func onSectionAppear(at index: Int) async { }
    func onDaySwipe(_ direction: DaySwipeDirection) { }
    func onToday() { }
    func onAdd() { }
    func handleCollectionEvent(_ event: TrackersCollectionOutput) { }
}
#endif
