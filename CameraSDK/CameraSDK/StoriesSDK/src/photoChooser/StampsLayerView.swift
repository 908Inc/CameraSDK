//
//  StampsLayerView.swift
//  Stories
//
//  Created by vlad on 9/2/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit
import SDWebImage

class StampsLayerView: UIView {
    var stampViews = [StampView]()
    var faceObjects: [Face]?
    weak var stampViewDelegate: StampViewDelegate?

    func addPositionedStamp(_ displayedStamp: StoryStamp) {
        guard let stampView = detectedStampView(forStamp: displayedStamp) else {
            printErr("no stampView")

            return
        }

        insert(newStampView: stampView)
    }

    func addStamp(_ displayedStamp: Stamp) {
        guard let stampView = centeredStampView(forStamp: displayedStamp) else {
            printErr("no stampView")

            return
        }

        insert(newStampView: stampView)
    }

    func addStamp(_ displayedStamp: Stamp, forRect rect: CGRect) {
        guard let stampView = fixedStampView(forStamp: displayedStamp, rect: rect) else {
            printErr("no stampView")

            return
        }

        insert(newStampView: stampView, animated: false)
    }

    func remove(stampView: StampView, animated: Bool = false, completion: SimpleBlock? = nil) {
        let remove = {
            self.stampViews.remove(stampView)
            stampView.removeFromSuperview()
            completion?()
        }

        if animated {
            shrink(stampView: stampView, duration: 0.3, completion: remove)
        } else {
            remove()
        }
    }

    func isPointInsideStamp(_ point: CGPoint) -> Bool {
        for stampView in stampViews {
            if stampView.frame.contains(point) && stampView.point(inside: convert(point, to: stampView), with: nil) {
                return true
            }
        }

        return false
    }

    func removeAllStamps(animated: Bool = false, completion: (()->())? = nil) {
        let group = DispatchGroup()

        for stampView in stampViews {
            group.enter()
            remove(stampView: stampView, animated: animated) {
                group.leave()
            }
        }

        group.notify(queue: DispatchQueue.main) {
            completion?()
        }
    }

    private func centeredStampView(forStamp stamp: Stamp, rect: CGRect? = nil) -> StampView? {
        guard let stampView = defaultStampView(for: stamp) else {return nil}

        stampView.center = CGPoint(x: width / 2, y: height / 2)

        let stampScale = 100 / stampView.width

        stampView.transform = stampView.transform.scaledBy(x: stampScale, y: stampScale)

        return stampView
    }

    private func fixedStampView(forStamp stamp: Stamp, rect: CGRect) -> StampView? {
        return defaultStampView(for: stamp, rect: rect)
    }

    private func detectedStampView(forStamp storyStamp: StoryStamp) -> StampView? {
        guard let stampView = defaultStampView(for: storyStamp) else {return nil}

        guard let faceObjects = faceObjects, let face = faceObjects.first else {
            printErr("no face object set; can't position")

            return nil
        }

        Positioner.automaticallyPosition(stampView, for: storyStamp, with: face, in: self)

        return stampView
    }

    private func insert(newStampView: StampView, animated: Bool = true, completion: SimpleBlock? = nil) {
        func insert() {
            addSubview(newStampView)
            stampViews.append(newStampView)
        }

        guard animated else {
            insert()

            return
        }

        let addHidden = {
            newStampView.isHidden = true
            insert()
        }

        addHidden()

        makeVisibleAndExpand(stampView: newStampView, duration: 0.3, completion: completion)
    }
}


extension StampsLayerView {
    fileprivate func defaultStampView(for imageSource: ImageSourceContainer, rect: CGRect? = nil) -> StampView? {
        guard let delegate = stampViewDelegate else {
            printErr("no delegate")

            return nil
        }

        guard let imageUrlString = imageSource.imageUrl, let imageUrl = URL(string: imageUrlString) else {
            printErr("no imageUrl provided")

            return nil
        }

        let newStampView = rect != nil ? StampView(delegate: delegate, frame: rect!) : StampView(delegate: delegate)

        newStampView.imageViewWithOverlay.sd_internalSetImage(with: imageUrl, placeholderImage: nil, options: SDWebImageOptions(rawValue: 0), operationKey: nil, setImageBlock: { [weak newStampView] image, data in
            newStampView?.imageViewWithOverlay.image = image
        }, progress: nil, completed: nil)

        return newStampView
    }
}


extension StampsLayerView {
    fileprivate func makeVisibleAndExpand(stampView: StampView, duration: TimeInterval, completion: SimpleBlock?) {
        let baseTransform = stampView.transform

        stampView.transform = stampView.transform.scaledBy(x: 0.1, y: 0.1)

        stampView.isHidden = false

        scale(stampView, to: baseTransform, via: baseTransform.scaledBy(x: 1.1, y: 1.1), completion: completion)
    }

    fileprivate func shrink(stampView: StampView, duration: TimeInterval, completion: SimpleBlock?) {
        let baseTransform = stampView.transform

        scale(stampView, to: baseTransform.scaledBy(x: 0.1, y: 0.1), via: baseTransform.scaledBy(x: 1.1, y: 1.1), completion: completion)
    }

    private func scale(_ view: UIView, to finalTransform: CGAffineTransform, via medialTransform: CGAffineTransform, duration: TimeInterval = 0.2, completion: SimpleBlock?) {
        UIView.animate(withDuration: duration, animations: {
            view.transform = medialTransform
        }) { _ in
            UIView.animate(withDuration: duration, animations: {
                view.transform = finalTransform
            }) { _ in
                completion?()
            }
        }
    }
}
