//
//  StoryChooserCell.swift
//  Stories
//
//  Created by vlad on 3/20/17.
//  Copyright © 2017 908. All rights reserved.
//

import UIKit

class StampPackChooserCell: UICollectionViewCell {
    @IBOutlet weak var collectionView: UICollectionView!

    fileprivate var delegate: StampPageViewControllerDelegate?

    fileprivate var images: [ImageSourceContainer]?

    func charge(withImagesArray images: [ImageSourceContainer], delegate: StampPageViewControllerDelegate) {
        self.images = images
        self.delegate = delegate
        collectionView.reloadData()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let delegate = self.delegate else {
            printErr("delegate isn't set")

            return
        }

        collectionView.contentInset.bottom = delegate.bottomOffset
        collectionView.contentInset.top = delegate.topOffset

        let numberOfCellsInRow = 4
        let defaultOffset = 10

        let totalOffset = numberOfCellsInRow * defaultOffset // 3 between cells and 1 for left / right offsets

        let cellWidth = (width - CGFloat(totalOffset)) / 4

        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            printErr("unexpected error")

            return
        }

        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
    }
}

extension StampPackChooserCell: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let images = images else {
            printErr("no images set; unexpected condition")

            return UICollectionViewCell()
        }

        guard indexPath.item < images.count else {
            printErr("incorrect number provided for numberOfItemsInSection")

            return UICollectionViewCell()
        }

        let storedImage = images[indexPath.item]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Ids.lStampViewCell, for: indexPath) as! StampViewCell
        cell.configureWithImageSource(storedImage)
        cell.didSelect = { [unowned self] in
            guard let delegate = self.delegate else {
                printErr("delegate isn't set")

                return
            }

            delegate.storedImageSelected(storedImage)
        }

        cell.movingStarted = { [unowned self, unowned collectionView] (started: Bool) in
            guard let delegate = self.delegate else {
                printErr("delegate isn't set")

                return
            }

            delegate.movingStarted(started)

            for visibleCell in collectionView.visibleCells {
                if visibleCell != cell {
                    UIView.animate(withDuration: 0.3, animations: {
                        visibleCell.alpha = started ? 0.0 : 1.0
                    })
                }
            }
        }

        cell.didLongTap = { [unowned self] (offset: CGPoint) in
            guard let delegate = self.delegate else {
                printErr("delegate isn't set")

                return
            }

            let rect = collectionView.layoutAttributesForItem(at: indexPath)?.frame

            let oldPoint = collectionView.convert(rect!, to: collectionView.superview).origin

            let newOffset = CGPoint(x: oldPoint.x + offset.x, y: oldPoint.y + offset.y);

            let translatedRect = CGRect(origin: newOffset, size: collectionView.convert(rect!, to: collectionView.superview).size)

            delegate.storedImageLongPressed(storedImage, fromCellWith: translatedRect)
        }

        return cell
    }
}


fileprivate enum Constants {

    enum Identifiers {
        static let lStampViewCell = "lStampViewCell"
    }

}

fileprivate typealias Ids = Constants.Identifiers
