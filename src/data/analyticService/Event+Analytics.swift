//
//  Event+Analytics.swift
//  Pods
//
//  Created by vlad on 4/6/17.
//
//

import Foundation

extension Event {
    func dictionaryRepresentation() -> [String: AnyHashable] {
        return [#keyPath(Event.label): label,
                #keyPath(Event.category): category,
                #keyPath(Event.action): action]
    }
}


extension Event {

    enum Action {
        static let share = "share"
        static let use = "use"
    }

}


extension Event {

    enum Category {
        static let stamp = "stamp"
        static let story = "story"
    }

}
