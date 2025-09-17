//
//  TrackersDeepLinksController.swift
//  Tracker
//
//  Created by Александр Зиновьев on 28.08.2025.
//

import Foundation
import Combine

protocol TrackersDeepLinksControlling {
    typealias Destination = TrackersDeepLinkDestination
    
    var deepLink: any Publisher<TrackersDeepLinkDestination?, Never> { get }
    
    func didAppear()
}

final class TrackersDeepLinksController: TrackersDeepLinksControlling {
    private let notificationDeepLinkService: any NotificationDeepLinkServiceProtocol
    private let reminderHandler = ReminderHandler()
    
    private var cancellable: Cancellable?
    private var wereHandlersRegistered = false
        
    private let mutableDeepLink: CurrentValueSubject<TrackersDeepLinkDestination?, Never> = .init(nil)
    var deepLink: any Publisher<TrackersDeepLinkDestination?, Never> { mutableDeepLink }
    
    init(
        notificationDeepLinkService: NotificationDeepLinkServiceProtocol
    ) {
        self.notificationDeepLinkService = notificationDeepLinkService
        
        cancellable = reminderHandler.deepLink
            .sink { [weak self] in self?.mutableDeepLink.send($0) }
    }
    
    func didAppear() {
        defer {
            wereHandlersRegistered = true
        }
        
        guard !wereHandlersRegistered else {
            return
        }
        
        notificationDeepLinkService.register(handler: reminderHandler)
    }
}

private extension TrackersDeepLinksController {
    final class ReminderHandler: NotificationDeepLinkHandler {
        private let mutableDeepLink: CurrentValueSubject<TrackersDeepLinkDestination?, Never> = .init(nil)
        var deepLink: any Publisher<TrackersDeepLinkDestination?, Never> { mutableDeepLink }
        
        init() { }
        
        func handle(link: Link) -> HandlingResult {
            mutableDeepLink.send(link.destination)
            
            return .handled
        }
        
        struct Link: DeepLinkProtocol {
            let rawValue: NotificationDeepLinkContext
            
            let destination: TrackersDeepLinkDestination
            
            init?(rawValue: NotificationDeepLinkContext) {
                self.rawValue = rawValue
                self.destination = rawValue.toDestination()
            }
        }
    }
}

private extension NotificationDeepLinkContext {
    func toDestination() -> TrackersDeepLinkDestination {
        switch type {
        case .weekly: .createTracker
        }
    }
}
