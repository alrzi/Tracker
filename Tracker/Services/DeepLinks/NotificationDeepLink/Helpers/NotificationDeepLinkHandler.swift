//
//  NotificationDeepLinkHandler.swift
//  Tracker
//
//  Created by Александр Зиновьев on 28.08.2025.
//

import Foundation
import DeepLink

protocol NotificationDeepLinkHandler: DeepLinkHandlerProtocol where RawValue == NotificationDeepLinkContext { }
