//
//  Face.swift
//  Stories
//
//  Created by vlad on 10/3/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit

class Face: FaceObject {
    var leftEye: FaceObject!
    var rightEye: FaceObject!
    var hat: FaceObject!
    var mouth: FaceObject!
    var mustache: FaceObject?
    var nose: FaceObject?

    func isComplete() -> Bool {
        return leftEye?.center != nil && rightEye?.center != nil
    }
}
