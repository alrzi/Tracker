//
//  PlaceholderSwiftUIView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import Foundation
import SwiftUI

struct PlaceholderSwiftUIView: View {
    let placeholder: Placeholder
    
    var body: some View {
        VStack(spacing: 12) {
            Image(placeholder.imageResource)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            
            Text(placeholder.info)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.black)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
    }
}

struct Placeholder {
    let imageResource: ImageResource
    let info: String
}

extension Placeholder {
    static let empty: Placeholder = .init(
        imageResource: ._05PlaceholderTracker,
        info: "Что будем отслеживать?"
    )
    
    static let emptySearch: Placeholder = .init(
        imageResource: ._13PlaceholderNoResult,
        info: "Ничего не найдено"
    )
    
    static let emptySections: Placeholder = .init(
        imageResource: ._05PlaceholderTracker,
        info: R.string.localizable.placeholderRecomendation()
    )
}

#Preview {
    ErrorView(onRetry: { })
        .background(.black)
}
