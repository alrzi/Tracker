//
//  GridView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import Foundation
import SwiftUI

struct GridView<T: View, Item: Equatable & Hashable & Identifiable> {
    @ObservedObject private var viewModel: GridViewModel<Item>
    
    private let columns: Int
    private let spacing: CGFloat
    private let content: (Item, Bool) -> T
    
    private var gridItems: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns)
    }
    
    init(
        viewModel: GridViewModel<Item>,
        columns: Int,
        spacing: CGFloat,
        content: @escaping (Item, Bool) -> T
    ) {
        self.viewModel = viewModel
        self.columns = columns
        self.spacing = spacing
        self.content = content
    }
}

extension GridView: View {
    var body: some View {
        LazyVGrid(columns: gridItems, spacing: spacing) {
            ForEach(viewModel.items) { item in
                content(item, viewModel.selectedItem == item)
                    .onTapGesture {
                        viewModel.selectItem(item)
                    }
            }
        }
    }
}
