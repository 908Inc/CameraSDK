//
//  ImageSourceContainer.swift
//  Stories
//
//  Created by vlad on 3/31/17.
//  Copyright © 2017 908. All rights reserved.
//

import Foundation

protocol ImageSourceContainer {
    var imageUrl: String? { get }
}

extension Stamp: ImageSourceContainer {
    public static func ==(lhs: Stamp, rhs: Stamp) -> Bool {
        return lhs.id == rhs.id
    }
}

extension StoryStamp: ImageSourceContainer {
    public static func ==(lhs: StoryStamp, rhs: StoryStamp) -> Bool {
        return lhs.id == rhs.id
    }
}
