//
//  UIView+Convenience.swift
//  Stories
//
//  Created by vlad on 8/27/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit

extension UIView {
    func setAnchorPoint(_ anchorPoint: CGPoint) {
        var newPoint = CGPoint(x: bWidth * anchorPoint.x, y: bHeight * anchorPoint.y)
        var oldPoint = CGPoint(x: bWidth * layer.anchorPoint.x, y: bHeight * layer.anchorPoint.y)

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x;

        position.y -= oldPoint.y;
        position.y += newPoint.y;

        layer.position = position;
        layer.anchorPoint = anchorPoint;
    }
}
