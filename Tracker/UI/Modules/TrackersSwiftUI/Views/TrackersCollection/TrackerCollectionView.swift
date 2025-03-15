//
//  TrackerCollectionView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.03.2025.
//

import SwiftUI
import TrackerDomain

struct VideoCollectionView<ViewModel: VideoCollectionViewModelProtocol>: View {
    @ObservedObject private var viewModel: ViewModel
    
    private let row = [
        GridItem(.adaptive(minimum: 170, maximum: 180), spacing: 5)
    ]
    
    private let rows = [
        GridItem(.adaptive(minimum: 170, maximum: 180), spacing: 5),
        GridItem(.adaptive(minimum: 170, maximum: 180), spacing: 5)
    ]
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.collection.title)
                .font(.system(size: 24, weight: .bold))
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                if viewModel.collection.trackers.count >= 3 {
                    LazyHGrid(rows: rows, spacing: 5) {
                        ForEach(viewModel.collection.trackers) { tracker in
                            TrackerItemView(tracker: tracker)
                                .frame(width: 200, height: 170)
                        }
                    }
                    .background(.blue)
                    .padding(.horizontal, 5)
                }
                else {
                    LazyHGrid(rows: row, spacing: 5) {
                        ForEach(viewModel.collection.trackers) { tracker in
                            TrackerItemView(tracker: tracker)
                                .frame(width: 200, height: 170)
                        }
                    }
                    .background(.blue)
                    .padding(.horizontal, 5)
                }
            }
            .background(.orange)
        }
        .background(.green)
    }
}

#if DEBUG
#Preview {
    VideoCollectionView(viewModel: CollectionViewModel())
}

final class CollectionViewModel: VideoCollectionViewModelProtocol {
    let collection: TrackerSection = .init(title: "Pinned", trackers: [])
}
#endif
