//
//  DeepLinkService.swift
//  Tracker
//
//  Created by Александр Зиновьев on 15.09.2020.
//

import Foundation

final class DeepLinkService<RawValue>: DeepLinkServiceProtocol where RawValue: Hashable {
    private var handlers: [Holder] = []
    private var rawValueQueue: [RawValue] = []
    
    func register<Handler>(
        handler: Handler
    ) where Handler: DeepLinkHandlerProtocol, Handler.RawValue == RawValue {
        handlers.append(Holder(handler))
        
        attemptToHandleQueuedRawValues(with: handler)
    }
    
    func handle(rawValue: RawValue) -> DeepLinkHandlingResult {
        var disposedHandlerIndices: [Int] = []
        
        var rawValueWasHandled = false
        
        for (index, handler) in handlers.enumerated() {
            switch handler.attemptHandle(rawValue: rawValue) {
            case .handled:
                rawValueWasHandled = true
                
            case .notHandled(let error):
                if
                    let handlerBoxError = error as? Errors,
                    case .handlerDisposed = handlerBoxError
                {
                    disposedHandlerIndices.append(index)
                }

            case .partiallyHandled:
                // Нужно чтобы какой-то хендлер для таких случаев
                // обязательно возвращал handled + соблюсти последовательность вызов
                break
            }
        }
        
        for index in disposedHandlerIndices.reversed() {
            handlers.remove(at: index)
        }
        
        if rawValueWasHandled {
            return .success
        }
        else {
            rawValueQueue.append(rawValue)
            return .enqueued
        }
    }
    
    private func attemptToHandleQueuedRawValues(
        with handler: some RawValueHandlerProtocol<RawValue>
    ) {
        var rawValuesToRemove: Set<RawValue> = []
        
        for rawValue in rawValueQueue {
            if case .handled = handler.attemptHandle(rawValue: rawValue) {
                rawValuesToRemove.insert(rawValue)
            }
        }
        
        rawValueQueue = rawValueQueue.filter { !rawValuesToRemove.contains($0) }
    }
}

private extension DeepLinkService {
    final class Holder: RawValueHandlerProtocol {
        private weak var handler: (any RawValueHandlerProtocol<RawValue>)?
        
        init(_ handler: any RawValueHandlerProtocol<RawValue>) {
            self.handler = handler
        }
        
        func attemptHandle(rawValue: RawValue) -> HandlingResult {
            guard let handler else {
                return .notHandled(Errors.handlerDisposed)
            }
            
            return handler.attemptHandle(rawValue: rawValue)
        }
    }

    enum Errors: Error {
        case handlerDisposed
    }
}
