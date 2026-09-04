//
//  NotificationDeepLinkService.swift
//  Tracker
//
//  Created by Александр Зиновьев on 28.08.2025.
//

import Foundation
import DeepLink

protocol NotificationDeepLinkServiceProtocol: Sendable {
    func register(handler: some NotificationDeepLinkHandler) async
    
    @discardableResult
    func handle(context: NotificationDeepLinkContext) async -> DeepLinkHandlingResult
}

final class NotificationDeepLinkService: NotificationDeepLinkServiceProtocol {
    private let deepLinkService: any DeepLinkServiceProtocol<NotificationDeepLinkContext>
    
    init(
        deepLinkService: some DeepLinkServiceProtocol<NotificationDeepLinkContext>
    ) {
        self.deepLinkService = deepLinkService
    }
    
    func register(handler: some NotificationDeepLinkHandler) async {
        await deepLinkService.register(handler: handler)
    }
    
    func handle(context: NotificationDeepLinkContext) async -> DeepLinkHandlingResult {
        await deepLinkService.handle(rawValue: context)
    }
}
