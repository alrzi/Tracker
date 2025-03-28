//
//  CommonButtonStyle.swift
//  Tracker
//
//  Created by Александр Зиновьев on 28.03.2025.
//

import Foundation
import SwiftUI

struct CommonButtonStyle: ButtonStyle {
    private let insets: EdgeInsets
    private let height: CGFloat
    private let maxWidth: CGFloat?
    
    private let backgroundColor: Color
    
    init(
        insets: EdgeInsets = EdgeInsets(),
        height: CGFloat = 64,
        maxWidth: CGFloat? = .infinity,
        backgroundColor: Color
    ) {
        self.insets = insets
        self.height = height
        self.maxWidth = maxWidth
        self.backgroundColor = backgroundColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .frame(maxWidth: maxWidth, minHeight: height)
            .background(backgroundColor)
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 16))
            .padding(insets)
    }
}
