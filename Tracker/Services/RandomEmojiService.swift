//
//  RandomEmojiService.swift
//  Tracker
//
//  Created by Александр Зиновьев on 04.08.2024.
//

import Foundation

enum RandomEmojiService {
    private static let emojiRanges: [ClosedRange<Int>] = [
        0x1F950...0x1F95F,
    ]
        
    static var emoji: String {
        let randomRange = emojiRanges.randomElement()
               
        if let randomRange {
            let randomScalarValue = Int.random(in: randomRange)
            
            if let scalar = UnicodeScalar(randomScalarValue) {
                return String(scalar)
            }
        }
        
        return ""
    }
}
