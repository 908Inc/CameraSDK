//
//  Array+RemoveObject.swift
//  Stories
//
//  Created by vlad on 8/16/16.
//  Copyright © 2016 908. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(_ object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
