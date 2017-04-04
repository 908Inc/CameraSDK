//
//  FaceObject.swift
//  Stories
//
//  Created by vlad on 10/3/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit

enum HPos: String {
    case left = "l"
    case center = "c"
    case right = "r"
}

enum VPos: String {
    case top = "t"
    case middle = "m"
    case bottom = "b"
}

typealias Position = (HPos?, VPos)

enum FaceTag: String {
    case eye = "type_eyes"
    case hat = "type_hat"
    case mouth = "type_mouth"
    case Static = "type_static"
    case face = "type_face"
    case frame = "type_frame"

    static func allTags() -> [FaceTag] {
        return [eye, hat, mouth, Static, face]
    }

    func sortIdx() -> Int {
        return FaceTag.allTags().index(of: self)!
    }

    static func allTagsRawValues() -> [String] {
        let allTags = self.allTags()

        var allTagsRawValues = [String]()

        for tag in allTags {
            allTagsRawValues.append(tag.rawValue)
        }

        return allTagsRawValues
    }
}

class FaceObject: NSObject {
    let rect: CGRect    //relative to screen size (points)
    let center: CGPoint?

    init(withRect rect: CGRect, center: CGPoint? = nil) {
        self.rect = rect

        self.center = center
    }
}
