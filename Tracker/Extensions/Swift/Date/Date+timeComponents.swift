//
//  Date+timeComponents.swift
//  Tracker
//
//  Created by Александр Зиновьев on 3/20/26.
//

import Foundation

extension Date {
    var timeComponents: (hour: Int, minute: Int) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: self)
        return (components.hour ?? 0, components.minute ?? 0)
    }
}
