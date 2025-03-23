//
//  TrackerCreationSwiftUIViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import Foundation

@MainActor
protocol TrackerCreationSwiftUIViewModelProtocol: ObservableObject {
    var newTrackerText: String { get set }
    var emojiViewModel: GridViewModel<TrackerCreationSwiftUIGridItem> { get }
    var colorsViewModel: GridViewModel<TrackerCreationSwiftUIGridItem> { get }
}

final class TrackerCreationSwiftUIViewModel: TrackerCreationSwiftUIViewModelProtocol {
    @Published var newTrackerText = ""
        
    let emojiViewModel = GridViewModel<TrackerCreationSwiftUIGridItem>(items: (0...17).map { _ in .init(value: RandomEmojiService.emoji) })
    let colorsViewModel = GridViewModel<TrackerCreationSwiftUIGridItem>(items: (0...17).map { _ in .init(value: RandomHexColorService.randomHexString) })
    
    init() {
        
    }
}
