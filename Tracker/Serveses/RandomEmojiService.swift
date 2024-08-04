//
//  RandomEmojiService.swift
//  Tracker
//
//  Created by Александр Зиновьев on 04.08.2024.
//

import Foundation

enum RandomEmojiService {
    // Define a range of Unicode scalar values for emojis
    private static let emojiRanges: [ClosedRange<Int>] = [
        0x1F600...0x1F64F, // Emoticons
        0x1F300...0x1F5FF, // Miscellaneous Symbols and Pictographs
        0x1F680...0x1F6FF, // Transport and Map Symbols
        0x1F700...0x1F77F, // Alchemical Symbols
        0x1F780...0x1F7FF, // Geometric Shapes Extended
        0x1F800...0x1F8FF, // Supplemental Arrows-C
        0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
        0x1FA00...0x1FAFF  // Chess Symbols
    ]
    
    // Function to get a random emoji
    static var emoji: String {
        // Select a random range from the predefined ranges
        let randomRange = emojiRanges.randomElement()!
        
        // Generate a random scalar value within the selected range
        let randomScalarValue = Int.random(in: randomRange)
        
        // Convert the scalar value to a Unicode scalar and then to a String
        if let scalar = UnicodeScalar(randomScalarValue) {
            return String(scalar)
        }
        
        return ""
    }
}
