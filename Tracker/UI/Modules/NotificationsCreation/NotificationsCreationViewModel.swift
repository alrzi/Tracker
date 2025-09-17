//
//  NotificationsCreationViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.08.2025.
//

import Foundation

protocol NotificationsCreationViewModelProtocol: ObservableObject {
    var title: String { get set }
    var subtitle: String { get set }
    var selectedDate: Date { get set }
    
    func onNotificationCreated()
}

final class NotificationsCreationViewModel: NotificationsCreationViewModelProtocol {
    @Published var title = ""
    @Published var subtitle = ""
    @Published var selectedDate: Date = .now
    
    init() { }
    
    func onNotificationCreated() {
    }
}
