//
//  Date+extensions.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 08.04.2025.
//

import Foundation

extension Date {
    func component(_ component: Calendar.Component) -> Int {
        Calendar.current.component(component, from: self)
    }
    
    func dateComponents(
        calendar: Calendar = .current,
        components: Set<Calendar.Component> = Set([.day, .month, .year])
    ) -> DateComponents {
        calendar.dateComponents(components, from: self)
    }
    
    func adjust(in calendar: Calendar = .current, _ component: Calendar.Component, offset: Int) -> Date {
        calendar.date(byAdding: component, value: offset, to: self) ?? self
    }
    
    func daysSince(in calendar: Calendar = .current, otherDate: Date) -> Int {
        let components = calendar.dateComponents([.day], from: otherDate, to: self)
        
        return components.day ?? 0
    }
}
