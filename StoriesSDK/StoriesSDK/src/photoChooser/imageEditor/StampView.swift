//
//  StampView.swift
//  Stories
//
//  Created by vlad on 8/10/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit

protocol StampViewDelegate: class {
    func touchEnded(_ ended: Bool, view: StampView)

    func centerMovedTo(point: CGPoint, view: StampViewProtocol)

    func doubleTap(forStampView stampView: StampView)
}

protocol StampViewProtocol: class {
    var removingMode: Bool { get set }
}

class StampView: UIView, UIGestureRecognizerDelegate, StampViewProtocol {
    weak var imageViewWithOverlay: ImageViewWithOverlay!

    private unowned let delegate: StampViewDelegate

    var touchEnabled = false

    var removingMode = false {
        didSet {
            imageViewWithOverlay.isOverlayEnabled = removingMode
        }
    }

    init(delegate: StampViewDelegate, frame: CGRect = CGRect(x: 0, y: 0, width: 160, height: 160)) {
        self.delegate = delegate

        super.init(frame: frame)

        clipsToBounds = true

        let imageViewWithOverlay = ImageViewWithOverlay()
        imageViewWithOverlay.contentMode = .scaleAspectFit
        addSubview(imageViewWithOverlay)
        imageViewWithOverlay.frame = bounds
        imageViewWithOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.imageViewWithOverlay = imageViewWithOverlay

        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(StampView.pinchGestureFired))
        pinchRecognizer.delegate = self
        addGestureRecognizer(pinchRecognizer)

        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(StampView.rotationGestureFired))
        rotationRecognizer.delegate = self
        addGestureRecognizer(rotationRecognizer)

        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(StampView.panGestureFired)))

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(StampView.doubleTapGestureFired))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)

        let tap = UITapGestureRecognizer(target: self, action: #selector(StampView.tapGestureFired))
        tap.require(toFail: doubleTap)
        addGestureRecognizer(tap)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return layer.color(ofPoint: point).alpha != 0
    }

    func doubleTapGestureFired(recognizer: UITapGestureRecognizer) {
        delegate.doubleTap(forStampView: self)
    }

    func tapGestureFired(recognizer: UITapGestureRecognizer) {
        //
        // call to reorder views
        delegate.touchEnded(true, view: self)
        //
    }

    func panGestureFired(recognizer: UIPanGestureRecognizer) {
        guard touchEnabled || recognizer.numberOfTouches <= 1 else {
            return
        }

        delegate.touchEnded(recognizer.state == .ended, view: self)

        if recognizer.state != .ended {
            let translation = recognizer.translation(in: self)
            if recognizer.view != nil {
                transform = transform.translatedBy(x: translation.x, y: translation.y)
                delegate.centerMovedTo(point: recognizer.location(in: self.superview), view: self)
            }
        }

        recognizer.setTranslation(CGPoint.zero, in: self.superview)
    }

    func pinchGestureFired(recognizer: UIPinchGestureRecognizer) {
        guard touchEnabled else {
            return
        }

        if recognizer.view != nil {
            transform = transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
        }

        recognizer.scale = 1.0
    }

    func rotationGestureFired(recognizer: UIRotationGestureRecognizer) {
        guard touchEnabled else {
            return
        }

        if recognizer.view != nil {
            transform = transform.rotated(by: recognizer.rotation)
        }

        recognizer.rotation = 0.0
    }


    //MARK: UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension CALayer {
    func color(ofPoint: CGPoint) -> CGColor {
        var pixel: [CUnsignedChar] = [0, 0, 0, 0]

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)

        context!.translateBy(x: -ofPoint.x, y: -ofPoint.y)

        self.render(in: context!)

        let red: CGFloat = CGFloat(pixel[0]) / 255.0
        let green: CGFloat = CGFloat(pixel[1]) / 255.0
        let blue: CGFloat = CGFloat(pixel[2]) / 255.0
        let alpha: CGFloat = CGFloat(pixel[3]) / 255.0

        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)

        return color.cgColor
    }
}
