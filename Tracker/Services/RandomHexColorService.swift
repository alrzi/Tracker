//
//  RandomHexColorService.swift
//  Tracker
//
//  Created by Александр Зиновьев on 04.08.2024.
//

import Foundation
import UIKit

enum RandomHexColorService {
    static var randomHexString: String {
        let randomInt = Int.random(in: 0x000000...0xFFFFFF)
                
        let hexString = String(format: "#%06X", randomInt)
                
        return hexString
    }
}
