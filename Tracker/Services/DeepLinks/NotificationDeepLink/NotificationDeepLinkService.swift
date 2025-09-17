//
//  NotificationDeepLinkService.swift
//  Tracker
//
//  Created by Александр Зиновьев on 28.08.2025.
//

import Foundation

protocol NotificationDeepLinkServiceProtocol {
    func register(handler: some NotificationDeepLinkHandler)
    
    @discardableResult
    func handle(context: NotificationDeepLinkContext) -> DeepLinkHandlingResult
}

final class NotificationDeepLinkService: NotificationDeepLinkServiceProtocol {
    private let deepLinkService: any DeepLinkServiceProtocol<NotificationDeepLinkContext>
    
    init(
        deepLinkService: some DeepLinkServiceProtocol<NotificationDeepLinkContext>
    ) {
        self.deepLinkService = deepLinkService
    }
    
    func register(handler: some NotificationDeepLinkHandler) {
        deepLinkService.register(handler: handler)
    }
    
    func handle(context: NotificationDeepLinkContext) -> DeepLinkHandlingResult {
        deepLinkService.handle(rawValue: context)
    }
}
