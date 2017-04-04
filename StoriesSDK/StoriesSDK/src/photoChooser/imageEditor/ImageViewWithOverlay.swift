//
//  ImageViewWithOverlay.swift
//  Stories
//
//  Created by vlad on 8/19/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit

class ImageViewWithOverlay: UIView {
    var isOverlayEnabled = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var image: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        image?.draw(in: rect)

        if isOverlayEnabled, let currentCtx = UIGraphicsGetCurrentContext() {
            currentCtx.saveGState()

            currentCtx.setBlendMode(CGBlendMode.sourceAtop)

            currentCtx.setFillColor(UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3).cgColor.components!)

            currentCtx.fill(rect)

            currentCtx.restoreGState()
        }
    }
}
