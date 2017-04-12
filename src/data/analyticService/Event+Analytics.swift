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

    enum Action: String {
        case share, use, push
    }

}


extension Event {

    enum Category: String {
         case stamp, story, appOpen = "app_open"
    }

}
