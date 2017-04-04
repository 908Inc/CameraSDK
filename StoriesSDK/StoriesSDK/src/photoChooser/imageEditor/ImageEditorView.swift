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
    fileprivate weak var imageView: UIImageView!
    private weak var panGestureRecognizer: UIPanGestureRecognizer?
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
        
        let imageView = UIImageView.layoutInst() as UIImageView

        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", metrics: nil, views: ["imageView": imageView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", metrics: nil, views: ["imageView": imageView]))

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
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stampsLayerView]|", metrics: nil, views: ["stampsLayerView": stampsLayerView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stampsLayerView]|", metrics: nil, views: ["stampsLayerView": stampsLayerView]))
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

    func getResultImage() throws -> (image: UIImage, path: URL) {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            throw ImageEditorViewError.noImageGenerated
        }

        guard let data = UIImagePNGRepresentation(image) else {
            throw ImageEditorViewError.noDataRepresentation
        }

        let writePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Image.png")

        try data.write(to: writePath)

        return (image, writePath)
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
