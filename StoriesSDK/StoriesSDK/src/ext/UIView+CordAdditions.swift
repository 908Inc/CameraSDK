//
//  UIView+CordAdditions.swift
//  iMsgStickerpipe
//
//  Created by vlad on 9/28/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit

extension UIView {
    var top: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame = CGRect.init(x: left,y: newValue, width: width, height: height)
        }
    }
    
    var left: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame = CGRect.init(x: newValue, y: top, width: width, height: height)
        }
    }
    
    var right: CGFloat {
        get {
            return frame.maxX
        }
        set {
            let difference = right - newValue
            
            left -= difference
        }
    }
    
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            self.frame = CGRect.init(x: left, y: top, width: newValue, height: height)
        }
    }
    
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame = CGRect.init(x: left, y: top, width: width, height: newValue)
        }
    }
    
    var bottom: CGFloat {
        get {
            return frame.maxY
        }
        set {
            let difference = bottom - newValue
            
            top -= difference
        }
    }
    
    var centerX: CGFloat {
        get {
            return center.x
        }
        set {
            center = CGPoint.init(x: newValue, y: centerY)
        }
    }
    
    var centerY: CGFloat {
        get {
            return center.y
        }
        set {
            center = CGPoint.init(x: centerX, y: newValue)
        }
    }
    
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            left = newValue.x
            top = newValue.y
        }
    }
    
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            width = newValue.width
            height = newValue.height
        }
    }
    
    // bounds
    
    var bTop: CGFloat {
        get {
            return bounds.origin.y
        }
        set {
            bounds = CGRect.init(x: left,y: newValue, width: width, height: height)
        }
    }
    
    var bLeft: CGFloat {
        get {
            return bounds.origin.x
        }
        set {
            bounds = CGRect.init(x: newValue, y: top, width: width, height: height)
        }
    }
    
    var bRight: CGFloat {
        get {
            return bounds.maxX
        }
        set {
            let difference = right - newValue
            
            left -= difference
        }
    }
    
    var bWidth: CGFloat {
        get {
            return bounds.size.width
        }
        set {
            bounds = CGRect.init(x: left, y: top, width: newValue, height: height)
        }
    }
    
    var bHeight: CGFloat {
        get {
            return bounds.size.height
        }
        set {
            bounds = CGRect.init(x: left, y: top, width: width, height: newValue)
        }
    }
    
    var bBottom: CGFloat {
        get {
            return bounds.maxY
        }
        set {
            let difference = bottom - newValue
            
            top -= difference
        }
    }
    
    var bCenterX: CGFloat {
        get {
            return center.x
        }
        set {
            center = CGPoint.init(x: newValue, y: centerY)
        }
    }
    
    var bCenterY: CGFloat {
        get {
            return center.y
        }
        set {
            center = CGPoint.init(x: centerX, y: newValue)
        }
    }
    
    var bOrigin: CGPoint {
        get {
            return bounds.origin
        }
        set {
            left = newValue.x
            top = newValue.y
        }
    }
    
    var bSize: CGSize {
        get {
            return bounds.size
        }
        set {
            width = newValue.width
            height = newValue.height
        }
    }
}


extension UIView {
    static func layoutInst() -> Self {
        return lI()
    }
    
    private static func lI<T: UIView>() -> T {
        let view = T()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }
}
