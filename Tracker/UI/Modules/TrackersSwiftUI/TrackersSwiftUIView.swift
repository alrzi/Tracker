//
//  TrackersSwiftUIView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.03.2025.
//

import SwiftUI
import Foundation

struct TrackersSwiftUIView<ViewModel: TrackersSwiftUIViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel
    
    @State private var queryString = ""
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - View

extension TrackersSwiftUIView: View {
    var body: some View {
        if viewModel.collectionViewModel.isEmpty {
            Text("Loading")
        }
        else {
            NavigationStack {
                ScrollView {
                    ForEach(viewModel.collectionViewModel) { collection in
                        VideoCollectionView(viewModel: collection)
                    }
                }
                .searchable(text: $queryString, placement: .navigationBarDrawer(displayMode: .always)) { }
                .navigationTitle("Trackers")
            }
        }
    }
}

#if DEBUG
#Preview {
    TrackersSwiftUIView(viewModel: ViewModel())
}

private final class ViewModel: TrackersSwiftUIViewModelProtocol {
    let collectionViewModel: [CollectionViewModel] = []
}
#endif
