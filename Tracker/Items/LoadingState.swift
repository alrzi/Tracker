//
//  LoadingState.swift
//  Tracker
//
//  Created by Александр Зиновьев on 18.03.2025.
//

import Foundation

enum LoadingState {
    case idle
    case loading
    case error(ErrorInfo)
    
    var isLoading: Bool {
        switch self {
        case .idle, .error: false
        case .loading: true
        }
    }
    
    var isError: Bool {
        switch self {
        case .idle, .loading: false
        case .error: true
        }
    }
    
    var error: ErrorInfo? {
        switch self {
        case .idle, .loading: nil
        case .error(let errorInfo): errorInfo
        }
    }
}

struct ErrorInfo: Identifiable {
    let id = UUID()
    let message: String
    let cancelButtonText: String
    let confirmationButtonText: String
    let onConfirm: () -> Void
}
