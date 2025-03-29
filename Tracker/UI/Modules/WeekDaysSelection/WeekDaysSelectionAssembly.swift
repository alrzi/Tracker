//
//  WeekDaysSelectionAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.03.2025.
//

import SwiftUI
import Foundation
import TrackerDomain

final class WeekDaysSelectionAssembly {
    private let weekDaysProvider: WeekDaysProvider
    
    init(weekDaysProvider: WeekDaysProvider = WeekDaysProvider()) {
        self.weekDaysProvider = weekDaysProvider
    }
    
    @MainActor
    func assemble(_ context: WeekDays, onCompletion: @MainActor @escaping (sending WeekDays) -> Void) -> some View {
        let view = WeekDaysSelectionView(
            weekDays: weekDaysProvider.getWeekDays(),
            selectedTags: context,
            onNext: { onCompletion($0) }
        )
        
        return view
    }
}
