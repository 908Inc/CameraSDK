//
// Created by vlad on 8/10/16.
// Copyright (c) 2016 908. All rights reserved.
//

import Foundation
import UIKit

enum ImageEditorViewError: Error {
    case noImageGenerated
    case noDataRepresentation
}

class ImageEditorView: UIView, StampViewDelegate, UIGestureRecognizerDelegate {
    weak var imageView: UIImageView!
    private weak var panGestureRecognizer: UIPanGestureRecognizer?

    var equalImageViewHeightConstraint: NSLayoutConstraint!
    var squareImageViewHeightConstraint: NSLayoutConstraint!

    var isSquareMode = false {
        didSet {
            equalImageViewHeightConstraint.isActive = !isSquareMode
            squareImageViewHeightConstraint.isActive = isSquareMode
        }
    }

    weak var stampsLayerView: StampsLayerView!
    weak var stampViewsDelegate: StampViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        customInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        customInit()
    }

    private func customInit() {
        backgroundColor = UIColor.clear
        
        let imageView = UIImageView.layoutInst()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", metrics: nil, views: ["imageView": imageView]))
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: imageView, attribute: .centerY, multiplier: 1, constant: 0))
        equalImageViewHeightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 1, constant: 0)
        squareImageViewHeightConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: 1, constant: 0)
        squareImageViewHeightConstraint.isActive = false

        addConstraints([equalImageViewHeightConstraint, squareImageViewHeightConstraint])


        self.imageView = imageView

        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ImageEditorView.pinchGestureFired))
        pinchRecognizer.delegate = self
        addGestureRecognizer(pinchRecognizer)

        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(ImageEditorView.rotationGestureFired))
        rotationRecognizer.delegate = self
        addGestureRecognizer(rotationRecognizer)

        let stampsLayerView = StampsLayerView.layoutInst() as StampsLayerView
        stampsLayerView.stampViewDelegate = self
        addSubview(stampsLayerView)
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: stampsLayerView, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: stampsLayerView, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: stampsLayerView, attribute: .width, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: stampsLayerView, attribute: .height, multiplier: 1, constant: 0))
        stampsLayerView.clipsToBounds = true
        self.stampsLayerView = stampsLayerView
    }

    func isPointInsideStamp(_ point: CGPoint) -> Bool {
        return stampsLayerView.isPointInsideStamp(point)
    }

    func pinchGestureFired(recognizer: UIPinchGestureRecognizer) {
        tryToTranslate(recognizer: recognizer, forMethod: #selector(StampView.pinchGestureFired))
    }

    func rotationGestureFired(recognizer: UIRotationGestureRecognizer) {
        tryToTranslate(recognizer: recognizer, forMethod: #selector(StampView.rotationGestureFired))
    }

    private func tryToTranslate(recognizer: UIGestureRecognizer, forMethod: Selector) {
        guard recognizer.numberOfTouches >= 2 else {
            return
        }

        for stampView in stampsLayerView.stampViews.reversed() {
            if checkIf(stamp: stampView, intersectedByLineFrom: recognizer.location(ofTouch: 0, in: self), to: recognizer.location(ofTouch: 1, in: self)) {
                stampView.perform(forMethod, with: recognizer)

                break
            }
        }
    }

    private func checkIf(stamp: StampView, intersectedByLineFrom point0: CGPoint, to point1: CGPoint) -> Bool {
        var intersect = StampUtility.intersectionOfLine(from: point0,
                to: point1,
                withLineFrom: CGPoint(x: stamp.left, y: stamp.top),
                to: CGPoint(x: stamp.right, y: stamp.bottom))

        if !intersect {
            intersect = StampUtility.intersectionOfLine(from: point0,
                    to: point1,
                    withLineFrom: CGPoint(x: stamp.right, y: stamp.top),
                    to: CGPoint(x: stamp.left, y: stamp.bottom))
        }

        return intersect
    }

    func getResultImage() throws -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        drawHierarchy(in: bounds, afterScreenUpdates: true)

        guard var image = UIGraphicsGetImageFromCurrentImageContext() else {
            throw ImageEditorViewError.noImageGenerated
        }

        if imageView.frame != frame {
            let cropRect = CGRect(x: imageView.left * image.scale, y: imageView.top * image.scale, width: imageView.width * image.scale, height: imageView.height * image.scale)

            guard let cgImage = image.cgImage, let croppedCgImage = cgImage.cropping(to: cropRect) else { return image }

            image = UIImage(cgImage: croppedCgImage)
        }

        return image
    }

    func setImage(_ image: UIImage?) {
        imageView.image = image
        originalImage = image

        if image == nil {
            stampsLayerView.removeAllStamps()
        }
    }


    //MARK: UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }


    // MARK: StampViewDelegate

    private func disable(_ disable: Bool, stampViewsExcept view: StampView?) {
        for stampView in stampsLayerView.stampViews {
            stampView.touchEnabled = !disable || stampView == view
        }
    }

    func doubleTap(forStampView stampView: StampView) {
        stampViewsDelegate?.doubleTap(forStampView: stampView)
    }

    func touchEnded(_ ended: Bool, view: StampView) {
        disable(!ended, stampViewsExcept: view)

        stampsLayerView.bringSubview(toFront: view)
        stampsLayerView.stampViews.insert(stampsLayerView.stampViews.remove(at: stampsLayerView.stampViews.index(of: view)!), at: stampsLayerView.stampViews.count)

        stampViewsDelegate?.touchEnded(ended, view: view)
    }

    func centerMovedTo(point: CGPoint, view: StampViewProtocol) {
        stampViewsDelegate?.centerMovedTo(point: point, view: view)
    }
}

fileprivate weak var originalImage: UIImage!

extension ImageEditorView {
    private func imageForFilter() -> UIImage? {
        guard let cgimg = originalImage.cgImage else {
            printErr("imageView doesn't have an image!")

            return nil
        }

        let coreImage = CIImage(cgImage: cgimg)

        let openGLContext = EAGLContext(api: .openGLES2)!
        let context = CIContext(eaglContext: openGLContext)

        let filterName = "CIPhotoEffectTransfer"

        if let filter = CIFilter(name: filterName) {
            filter.setValue(coreImage, forKey: kCIInputImageKey)

            if let output = filter.value(forKey: kCIOutputImageKey) as? CIImage {
                if let cgImageResult = context.createCGImage(output, from: output.extent) {
                    return UIImage(cgImage: cgImageResult)
                }
            } else {
                printErr("image filtering failed")
            }
        } else {
            printErr("no such filter")
        }

        return nil
    }

    func changeFilter(animated: Bool = true, completion: SimpleBlock? = nil) {
        if let filteredImage = imageForFilter() {
            let fakeImageView = UIImageView(image: filteredImage)
            fakeImageView.contentMode = .scaleAspectFill
            fakeImageView.translatesAutoresizingMaskIntoConstraints = false

            fakeImageView.alpha = 0

            imageView.addSubview(fakeImageView)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[fakeImageView]|", metrics: nil, views: ["fakeImageView": fakeImageView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[fakeImageView]|", metrics: nil, views: ["fakeImageView": fakeImageView]))

            UIView.animate(withDuration: 0.25, animations: {
                fakeImageView.alpha = 1.0
            }) { (completed) in
                self.imageView.image = filteredImage
                fakeImageView.removeFromSuperview()

                completion?()
            }
        } else {
            printErr("no filtered image")
        }
    }
}


// cords
extension ImageEditorView {
    var distanceFromImageToBottom: CGFloat {
        return height - imageView.bottom
    }
}
