//
//  TrackerFormGridOptions.swift
//  Tracker
//
//  Created by Александр Зиновьев on 04.09.2026.
//

import Foundation

enum TrackerFormGridOptions {
    // MARK: - Static properties

    static let emojiItems = [
        "🥦", "🥕", "🌽", "🍇", "🍓", "🍎",
        "🍋", "🍉", "🥑", "🍅", "🥒", "🍞",
        "🧀", "🍗", "🍕", "🍔", "🍣", "🍩"
    ].map(TrackerFormGridItem.init)

    static let colorItems = [
        "#FD4C49", "#FF8811", "#F8CC00", "#A7C957", "#4CAF50", "#00BFA5",
        "#00BCD4", "#2196F3", "#3F51B5", "#673AB7", "#9C27B0", "#E91E63",
        "#795548", "#9E9E9E", "#607D8B", "#FF6B6B", "#6C5CE7", "#2D3436"
    ].map(TrackerFormGridItem.init)
}
