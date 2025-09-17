//
//  Color.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import Foundation
import SwiftUI

extension Color {
    init?(hexString: String) {
        // Remove the hash if it's there
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }
        
        // Ensure the hex string is valid
        guard hex.count == 6 || hex.count == 8 else {
            return nil
        }
        
        // Convert the hex string to an integer
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        
        // Extract the red, green, blue, and alpha components
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        let alpha = hex.count == 8 ? Double((rgb >> 24) & 0xFF) / 255.0 : 1.0
        
        // Initialize the Color
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
}
