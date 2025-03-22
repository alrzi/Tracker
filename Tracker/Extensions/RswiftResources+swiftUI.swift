//
//  RswiftResources+swiftUI.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import Foundation
import RswiftResources
import SwiftUI

extension FontResource {
    func font(size: CGFloat) -> Font {
        Font.custom(name, size: size)
    }
}

extension RswiftResources.ColorResource {
    var color: Color {
        Color(name)
    }
}

extension StringResource {
    var text: Text {
        Text(
            LocalizedStringKey(key.description),
            tableName: tableName,
            bundle: source.bundle
        )
    }
}

extension RswiftResources.ImageResource {
    var image: Image {
        Image(name)
    }
}
