//
//  TrackersSwiftUIView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.03.2025.
//

import SwiftUI
import Foundation
import TrackerDomain

struct TrackersSwiftUIView<ViewModel: TrackersSwiftUIViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel       
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - View

extension TrackersSwiftUIView: View {
    var body: some View {
        // swiftlint:disable closure_body_length
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    VStack {
                        Spacer()
                        Text("Loading")
                        Spacer()
                    }
                    
                case .loaded(let models):
                    ScrollableLazyVStack(horizontalPadding: 0) {
                        ForEach(Array(models.enumerated()), id: \.element.id) { index, collection in
                            VideoCollectionView(viewModel: collection)
                                .padding(.horizontal, 12)
                                .onAppear { viewModel.onSectionAppear(at: index) }
                        }
                        
                        if viewModel.isPaginating {
                            ProgressView()
                                .scaleEffect(2)
                                .tint(.white)
                                .padding(.vertical, 16)
                        }
                    }
                    
                case .error:
                    VStack {
                        Spacer()
                        Text("Erorr")
                        Spacer()
                    }
                }
            }
            .safeAreaInset(edge: .bottom, alignment: .trailing) {
                Button(action: { }) {
                    Image(systemName: "plus")
                        .resizable()
                        .symbolVariant(.circle.fill)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .blue)
                }
                .frame(width: 60, height: 60)
                .padding(20)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DatePicker("", selection: $viewModel.currentDate, displayedComponents: .date)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker(selection: $viewModel.filter, label: Text("Filters")) {
//                            Button(action: {}) {
//                                Text("All")
//                            }
//                            .tag(TrackerFilter.forCurrentWeekDay)
//                            
//                            Button(action: {}) {
//                                Label("Completed", systemImage: "checklist.checked")
//                            }
//                            .tag(TrackerFilter.completedForDate)
//                            
//                            Button(action: {}) {
//                                Label("In progress", systemImage: "checklist.unchecked")
//                            }
//                            .tag(TrackerFilter.uncompletedForDate)
                            
                            ForEach(TrackerFilter.allCases, id: \.self) { option in
                                Text(option.name).tag(option)
                            }
                        }
                    }
                    label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
            }
        }
        .searchable(text: $viewModel.queryString) { }
    }
}

#if DEBUG
#Preview {
    TrackersSwiftUIView(viewModel: ViewModel())
}

private final class ViewModel: TrackersSwiftUIViewModelProtocol {
    var filter: TrackerFilter = .completedForDate
    var queryString: String = ""
    var currentDate: Date = .now
    let isPaginating = false
    let state: TrackersState<CollectionViewModel> = .idle
        
    func onSectionAppear(at index: Int) { }
}
#endif
