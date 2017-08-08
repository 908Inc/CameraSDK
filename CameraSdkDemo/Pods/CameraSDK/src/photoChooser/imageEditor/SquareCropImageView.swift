//
//  SquareCropImageView.swift
//  Pods
//
//  Created by vlad on 6/2/17.
//
//

import UIKit

class SquareCropImageView: UIView {
    weak var imageView: UIImageView!
    weak var overlayView: UIView!

    init(image: UIImage) {
        super.init(frame: CGRect())

        let imageView = UIImageView.layoutInst()
        addSubview(imageView)
        imageView.image = image

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", metrics: nil, views: ["imageView": imageView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", metrics: nil, views: ["imageView": imageView]))

        self.imageView = imageView

        let overlayView = SquareOverlayView.layoutInst()
        addSubview(overlayView)
        self.overlayView = overlayView
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[overlayView]|", metrics: nil, views: ["overlayView": overlayView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[overlayView]|", metrics: nil, views: ["overlayView": overlayView]))
        
//        squareView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(SquareOverlayView.panGestureFired)))
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }

    func panGestureFired(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state != .ended {
            let translation = recognizer.translation(in: self)
            if recognizer.view != nil {
//                squareView.top = min(max(squareView.top + translation.y, 0), height - squareView.height)
                setNeedsDisplay()
            }
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self.superview)
    }

    class SquareOverlayView: UIView {
        weak var squareView: UIView!

        public override init(frame: CGRect) {
            super.init(frame: frame)

            backgroundColor = .clear

            let squareView = UIView()
            addSubview(squareView)
            self.squareView = squareView
        }
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError("not implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            
            squareView.height = width
            squareView.width = width
            squareView.center = CGPoint(x: width / 2, y: height / 2)
            squareView.layer.borderColor = UIColor.white.cgColor
            squareView.layer.borderWidth = 1
            
            setNeedsDisplay()
        }
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)

            guard let context = UIGraphicsGetCurrentContext() else { return }

            context.setFillColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor)

            let topRect = CGRect(origin: CGPoint(), size: CGSize(width: width, height: squareView.top))
            let bottomRect = CGRect(origin: CGPoint(x: 0, y: squareView.bottom), size: CGSize(width: width, height: height - squareView.bottom))

            context.fill(topRect)
            context.fill(bottomRect)
        }
    }
}

