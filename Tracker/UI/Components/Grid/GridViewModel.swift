//
//  GridViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import Foundation

final class GridViewModel<T: Equatable & Hashable & Identifiable>: ObservableObject {
    @Published private(set) var items: [T]
    @Published private(set) var selectedItem: T?
    
    init(
        items: [T],
        selectedItem: T? = nil
    ) {
        self.items = items
        self.selectedItem = selectedItem
    }
    
    func selectItem(_ item: T) {
        selectedItem = item
    }
}
