//
//  StampViewCell.swift
//  Stories
//
//  Created by vlad on 9/30/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit
import SDWebImage

class StampViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    private var imageSource: ImageSourceContainer!

    private var stampImageView: UIImageView!
    private var allowMoving = false

    var didSelect: SimpleBlock!
    var movingStarted: BoolBlock!
    var didLongTap: PointBlock!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        customize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize()
    }

    private func customize() {
        backgroundColor = UIColor.clear

        let stampImageView = UIImageView.layoutInst()

        stampImageView.contentMode = .scaleAspectFit
        addSubview(stampImageView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stampImageView]|", metrics: nil, views: ["stampImageView": stampImageView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stampImageView]|", metrics: nil, views: ["stampImageView": stampImageView]))
        self.stampImageView = stampImageView

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StampViewCell.tapFired))
        addGestureRecognizer(tapGestureRecognizer)

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(StampViewCell.longPressFired))
        longPressRecognizer.delegate = self
        tapGestureRecognizer.require(toFail: longPressRecognizer)
        addGestureRecognizer(longPressRecognizer)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(StampViewCell.panPressFired))
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)
    }

    func configureWithImageSource(_ imageSource: ImageSourceContainer) {
        self.imageSource = imageSource

        setUpStickerFromStickerObject()
    }

    private func setUpStickerFromStickerObject() {
        guard let imageUrlString = imageSource.imageUrl, let imageUrl = URL(string: imageUrlString) else {
            printErr("invalid url")

            return
        }

        stampImageView.sd_setImage(with: imageUrl, completed: { [weak self] image, error, cache, url in
            guard let strongSelf = self else {
                return
            }

            guard url?.absoluteString == strongSelf.imageSource.imageUrl else {
                return
            }

            guard error == nil else {
                printErr("error while getting image", error: error)

                return
            }

            DispatchQueue.main.async {
                strongSelf.stampImageView.image = image
            }
        })
    }

    func tapFired() {
        didSelect()
    }

    func longPressFired(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            allowMoving = true

            UIView.animate(withDuration: 0.3) {
                self.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
            }

            movingStarted(true)
        } else if recognizer.state == .ended {
            allowMoving = false

            let newPoint = CGPoint(x: centerX + transform.tx, y: centerY + transform.ty)
            let oldPoint = center

            let translationX = transform.tx
            let translationY = transform.ty

            UIView.animate(withDuration: 0.35, animations: {
                self.center = newPoint
                self.transform = CGAffineTransform.identity
            }) { (_) in
                self.didLongTap(CGPoint(x: translationX, y: translationY))

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    self.center = oldPoint
                    self.movingStarted(false)
                }
            }
        }
    }

    func panPressFired(recognizer: UIPanGestureRecognizer) {
        if self.allowMoving {
            if recognizer.state != .ended {
                let translation = recognizer.translation(in: self)
                if recognizer.view != nil {
                    transform = transform.translatedBy(x: translation.x, y: translation.y)
                }
            }
        }

        recognizer.setTranslation(CGPoint.zero, in: self)
    }


    //MARK: StickerViewCellBase

    override func prepareForReuse() {
        super.prepareForReuse()

        stampImageView.image = nil
    }

    func hideStickerImage(_ isHide: Bool) {
        if (isHide) {
            stampImageView.alpha = 0.0
        } else {
            stampImageView.alpha = 1.0
        }
    }


    // MARK: UIGestureRecognizerDelegate

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if allowMoving {
            return gestureRecognizer.view == self && otherGestureRecognizer.view == self
        }

        return true
    }
}
