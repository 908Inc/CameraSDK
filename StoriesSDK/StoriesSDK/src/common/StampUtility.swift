//
//  StampUtility.swift
//  Stories
//
//  Created by vlad on 10/3/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit

class StampUtility: Utility {
    static func intersectionOfLine(from p1: CGPoint, to p2: CGPoint, withLineFrom p3: CGPoint, to p4: CGPoint) -> Bool {
        let d = (p2.x - p1.x) * (p4.y - p3.y) - (p2.y - p1.y) * (p4.x - p3.x)
        if d == 0 {
            return false // parallel lines
        }
        let u = ((p3.x - p1.x) * (p4.y - p3.y) - (p3.y - p1.y) * (p4.x - p3.x)) / d
        let v = ((p3.x - p1.x) * (p2.y - p1.y) - (p3.y - p1.y) * (p2.x - p1.x)) / d
        if u < 0.0 || u > 1.0 {
            return false // intersection point not between p1 and p2
        }
        if (v < 0.0 || v > 1.0) {
            return false // intersection point not between p3 and p4
        }

        return true
    }
}
