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
    @GestureState private var swipeTranslation: CGSize = .zero
    
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
        }
        .searchable(text: $viewModel.queryString) { }
        .overlay {
            EdgeSwipeHints(translation: swipeTranslation)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
        }
        .onAppear(perform: viewModel.onAppear)
    }
}

private struct EdgeSwipeHints: View {
    let translation: CGSize

    var body: some View {
        let isHorizontal = abs(translation.width) > abs(translation.height) * 1.25
        let progress = isHorizontal ? min(abs(translation.width) / 70, 1) : 0

        HStack {
            EdgeSwipeArc(
                edge: .leading,
                progress: translation.width > 0 ? progress : 0
            )

            Spacer()

            EdgeSwipeArc(
                edge: .trailing,
                progress: translation.width < 0 ? progress : 0
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct EdgeSwipeArc: View {
    enum Edge {
        case leading
        case trailing
    }

    let edge: Edge
    let progress: CGFloat

    var body: some View {
        EdgeArcShape(edge: edge)
            .fill(Color.accentColor.opacity(0.12))
            .overlay {
                EdgeArcShape(edge: edge)
                    .stroke(
                        Color.accentColor.opacity(0.35),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
            }
            .frame(width: 18, height: 72)
            .opacity(progress * 0.8)
            .scaleEffect(0.8 + progress * 0.2)
            .offset(x: edge == .leading ? -18 * (1 - progress) : 18 * (1 - progress))
    }
}

private struct EdgeArcShape: Shape {
    let edge: EdgeSwipeArc.Edge

    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 44
        let center = CGPoint(
            x: edge == .leading ? -radius * 0.65 : rect.width + radius * 0.65,
            y: rect.midY
        )
        let angles: (start: Angle, end: Angle) = switch edge {
        case .leading: (.degrees(-45), .degrees(45))
        case .trailing: (.degrees(135), .degrees(225))
        }

        var path = Path()
        path.move(to: center)
        path.addLine(
            to: CGPoint(
                x: center.x + radius * CGFloat(cos(angles.start.radians)),
                y: center.y + radius * CGFloat(sin(angles.start.radians))
            )
        )
        path.addArc(
            center: center,
            radius: radius,
            startAngle: angles.start,
            endAngle: angles.end,
            clockwise: false
        )
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
    func onDaySwipe(_ direction: DaySwipeDirection) { }
    func onToday() { }
    func onAdd() { }
}
#endif
