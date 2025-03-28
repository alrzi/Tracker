//
//  ScrollableLazyVStack.swift
//  Tracker
//
//  Created by Александр Зиновьев on 18.03.2025.
//

import Foundation
import SwiftUI

struct ScrollableLazyVStack<Content: View> {
    private let horizontalPadding: CGFloat
    private let spacing: CGFloat?
    private let showsIndicators: Bool
    private let content: Content
       
    init(
        showsIndicators: Bool = false,
        spacing: CGFloat? = nil,
        horizontalPadding: CGFloat = 16,
        @ViewBuilder contentBuilder: () -> Content
    ) {
        self.showsIndicators = showsIndicators
        self.spacing = spacing
        self.horizontalPadding = horizontalPadding
        content = contentBuilder()
    }
}

extension ScrollableLazyVStack: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: showsIndicators) {
            LazyVStack(spacing: spacing) {
                content
            }
            .padding(.horizontal, horizontalPadding)
        }
    }
}
