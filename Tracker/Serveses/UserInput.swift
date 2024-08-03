//
//  UserInputCollector.swift
//  Tracker
//
//  Created by Александр Зиновьев on 21.07.2024.
//

import Combine

enum UserInputValue: Hashable {
    case name(String?)
    case color(String?)
    case emoji(String?)
    case weekDays(Set<Int>)
    case category(TrackerSection?)
    case kind(TrackerKind)
}

final class UserInputCollector {
    private let name: CurrentValueSubject<String?, Never> = .init(nil)
    private let color: CurrentValueSubject<String?, Never> = .init(nil)
    private let emoji: CurrentValueSubject<String?, Never> = .init(nil)
    private let trackerCategory: CurrentValueSubject<TrackerSection?, Never> = .init(nil)
    private let weekDays: CurrentValueSubject<Set<Int>, Never> = .init([])
    private let kind: CurrentValueSubject<TrackerKind, Never> = .init(.habit)
    
    private let trackerSubject = PassthroughSubject<Tracker, Never>()
    var trackerPublisher: some Publisher<Tracker, Never> { trackerSubject }
    
    private let weekDaysSubject = PassthroughSubject<Set<Int>, Never>()
    var weekDaysPublisher: some Publisher<Set<Int>, Never> { weekDaysSubject }
    
    private let categorySubject = PassthroughSubject<TrackerSection, Never>()
    var categoryPublisher: some Publisher<TrackerSection, Never> { categorySubject }
    
    var schedule: Set<Int> { weekDays.value }
    
    private var cancellable: Set<AnyCancellable> = []
    
    init() {
        Publishers.CombineLatest4(name, color, emoji, trackerCategory)
            .combineLatest(Publishers.CombineLatest(weekDays, kind))
            .compactMap { value in
                let (name, color, emoji, category) = value.0
                let (weekDays, kind) = value.1
                
                guard 
                    let name = name,
                    !name.isEmpty,
                    let emoji = emoji,
                    !emoji.isEmpty,
                    let color = color,
                    !color.isEmpty,
                    let category = category,
                    !category.title.isEmpty,
                    !weekDays.isEmpty
                else {
                    return nil
                }
                               
                return Tracker(
                    name: name,
                    emoji: emoji,
                    color: color,
                    schedule: weekDays,
                    kind: kind,
                    trackedDays: .zero
                )
            }            
            .sink { [weak self] in self?.trackerSubject.send($0) }
            .store(in: &cancellable)
        
        weekDays            
            .sink { [weak self] in self?.weekDaysSubject.send($0) }
            .store(in: &cancellable)
        
        trackerCategory
            .compactMap({ $0 })
            .sink { [weak self] in self?.categorySubject.send($0) }
            .store(in: &cancellable)
    }
    
    func insert(_ key: UserInputValue) {
        switch key {
        case .name(let string): name.send(string)
        case .color(let string): color.send(string)
        case .emoji(let string): emoji.send(string)
        case .weekDays(let set): weekDays.send(set)
        case .category(let category): trackerCategory.send(category)
        case .kind(let trackerKind): kind.send(trackerKind)
        }
    }
    
    func setTracker(_ tracker: Tracker) {
        name.send(tracker.name)
        color.send(tracker.color)
        emoji.send(tracker.emoji)
        weekDays.send(tracker.weekDays)
        kind.send(tracker.kind)
    }
}
