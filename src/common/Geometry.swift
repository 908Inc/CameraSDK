//
//  Geometry.swift
//  Stories
//
//  Created by vlad on 10/6/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit

struct Line {
    var start: CGPoint
    var end: CGPoint

    var center: CGPoint {
        return CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
    }

    var length: CGFloat {
        return sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2))
    }

    mutating func offsetCoordinates(for points: CGFloat) {
        let x1p = start.x + points * (end.y - start.y) / length
        let x2p = end.x + points * (end.y - start.y) / length
        let y1p = start.y + points * (start.x - end.x) / length
        let y2p = end.y + points * (start.x - end.x) / length

        self = Line(start: CGPoint(x: x1p, y: y1p), end: CGPoint(x: x2p, y: y2p))
    }

    mutating func tiltEnd(forAngle angle: CGFloat) {
        end = start + CGPoint(x: length * cos(angle), y: length * sin(angle))
    }

    func angleTo(line: Line) -> CGFloat {
        let angle1 = atan2(end.y - start.y, start.x - end.x)
        let angle2 = atan2(line.end.y - line.start.y, line.start.x - line.end.x)
        return angle1 - angle2 + CGFloat.pi
    }

    func scaleFrom(line: Line) -> CGFloat {
        let lengthA = sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2))
        let lengthB = sqrt(pow(line.end.x - line.start.x, 2) + pow(line.end.y - line.start.y, 2))
        return lengthB / lengthA
    }
}

extension CGRect {
    func topLine() -> Line {
        return Line(start: origin, end: CGPoint(x: origin.x + size.width, y: origin.y))
    }

    func leftLine() -> Line {
        return Line(start: origin, end: CGPoint(x: origin.x, y: origin.y + size.height))
    }
}

extension CGSize {
    static func /(left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width: left.width / right, height: left.height / right)
    }

    static func *(left: CGSize, right: CGPoint) -> CGSize {
        return CGSize(width: left.width * right.x, height: left.height * right.y)
    }
}

extension CGPoint {
    static func *(left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }

    static func *(left: CGPoint, right: CGSize) -> CGPoint {
        return CGPoint(x: left.x * right.width, y: left.y * right.height)
    }

    static func /(left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x / right, y: left.y / right)
    }

    static func +(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    static func +(left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x + right, y: left.y + right)
    }

    static func +(left: CGPoint, right: CGSize) -> CGPoint {
        return CGPoint(x: left.x + right.width, y: left.y + right.height)
    }

    static func -(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    static func -=(left: inout CGPoint, right: CGPoint) {
        left = left - right
    }

    static func +=(left: inout CGPoint, right: CGPoint) {
        left = left + right
    }

    static func +=(left: inout CGPoint, right: CGFloat) {
        left = left + right
    }

    static func -(left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x - right, y: left.y - right)
    }
}
