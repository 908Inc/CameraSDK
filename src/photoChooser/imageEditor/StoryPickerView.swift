//
//  StoryPickerView.swift
//  Stories
//
//  Created by vlad on 3/10/17.
//  Copyright © 2017 908. All rights reserved.
//

import UIKit
import SDWebImage

protocol StoryPickerViewDelegate: class {
    var placeholderImage: UIImage { get }

    func selectedIdxChanged(_ idx: Int)

    func presentationChanged(_ presentation: StoryPickerViewPresentation)

    func shouldReceiveTouch(for point: CGPoint) -> Bool

    func pickerPositionChanged(_ value: CGFloat)
}

extension StoryPickerViewDelegate {
    func pickerPositionChanged(_ value: CGFloat) {
    }
}

enum StoryPickerViewPresentation {
    case shown, hidden, locked
}

class StoryPickerView: UIScrollView {
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet fileprivate weak var selectorImageView: UIView! {
        didSet {
            selectorImageView.layer.cornerRadius = selectorImageView.width / 2
            selectorImageView.layer.borderWidth = 5
            selectorImageView.layer.borderColor = UIColor.white.cgColor
        }
    }
    @IBOutlet fileprivate weak var collectionViewBottomConstraint: NSLayoutConstraint!

    weak var storyPickerDelegate: StoryPickerViewDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        customize()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        customize()
    }

    private func customize() {
        delegate = self
    }

    var constantForPickerHidden: CGFloat {
        return 0
    }

    var constantForPickerShown: CGFloat {
        return collectionView.height
    }

    var imageUrls: [URL?]? {
        didSet {
            // call this to invalidate insets
            layoutIfNeeded()

            let noUrls = (imageUrls?.count ?? 0) == 0

            if noUrls {
                presentation = .locked
            } else {
                selectIdx(0)
                presentation = .shown
            }

            collectionView.reloadData()
        }
    }

    func selectIdx(_ idx: Int) {
        scrollAndChangeSelectionIfNeeded(to: idx)
        selectedIdx = idx
    }

    func changePresentation(_ newPresentation: StoryPickerViewPresentation, animated: Bool = true) {
        layoutIfNeeded()

        if newPresentation == .shown {
            collectionViewBottomConstraint.constant = constantForPickerShown
        } else {
            collectionViewBottomConstraint.constant = constantForPickerHidden
        }

        if animated {
            UIView.animate(withDuration: 0.3) { _ in
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }

        isUserInteractionEnabled = newPresentation != .locked

        presentation = newPresentation

        guard let storyPickerDelegate = storyPickerDelegate else {
            printErr("storyPickerDelegate isn't set")

            return
        }

        storyPickerDelegate.presentationChanged(newPresentation)
    }

    private(set) var presentation = StoryPickerViewPresentation.hidden

    fileprivate(set) var selectedIdx: Int = -1 {
        didSet {
            guard let storyPickerDelegate = storyPickerDelegate else {
                printErr("storyPickerDelegate isn't set")

                return
            }

            storyPickerDelegate.selectedIdxChanged(selectedIdx)
        }
    }

    @IBAction func selectorViewTapped(_ sender: UITapGestureRecognizer) {
        changePresentation(.hidden)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // only need this procession for cases, when picker is hidden
        guard presentation == .hidden else {
            return super.point(inside: point, with: event)
        }

        guard let storyPickerDelegate = storyPickerDelegate else {
            return super.point(inside: point, with: event)
        }

        return super.point(inside: point, with: event) && storyPickerDelegate.shouldReceiveTouch(for: point)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.layoutIfNeeded()

        let sideOffset = (collectionView.width - selectorImageView.width) / 2

        collectionView.contentInset = UIEdgeInsets(top: 0, left: sideOffset, bottom: 0, right: sideOffset)

        contentSize = CGSize(width: width + 10, height: height + collectionView.height)
    }
}


extension StoryPickerView: UIScrollViewDelegate, UICollectionViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self else {
            return
        }

        enum ScrollDirection {
            case horizontal, vertical
        }

        var scrollDirection: ScrollDirection

        if abs(scrollView.contentOffset.x) > abs(scrollView.contentOffset.y) {
            scrollDirection = .horizontal
        } else {
            scrollDirection = .vertical
        }

        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            printErr("wrong layout")

            return
        }

        defer {
            contentOffset = CGPoint()
        }

        if scrollDirection == .horizontal {
            guard presentation == .shown else {
                // disable horizontal scrolling for hidden picker

                return
            }

            let maxOffset = collectionView.contentSize.width - collectionView.contentInset.left - layout.itemSize.width
            let minOffset = -collectionView.contentInset.left

            let currentCollectionViewOffsetX = collectionView.contentOffset.x
            let newOffset = currentCollectionViewOffsetX + scrollView.contentOffset.x

            if newOffset >= maxOffset {
                collectionView.contentOffset = CGPoint(x: maxOffset, y: 0)

                selectClosestCell()

                return
            }

            if newOffset <= minOffset {
                collectionView.contentOffset = CGPoint(x: minOffset, y: 0)

                selectClosestCell()

                return
            }

            collectionView.contentOffset = CGPoint(x: newOffset, y: 0)
        } else {
            if collectionViewBottomConstraint.constant + contentOffset.y > constantForPickerShown {
                collectionViewBottomConstraint.constant = constantForPickerShown
            } else if collectionViewBottomConstraint.constant + contentOffset.y < constantForPickerHidden {
                collectionViewBottomConstraint.constant = constantForPickerHidden
            } else {
                collectionViewBottomConstraint.constant += contentOffset.y
            }

            layoutIfNeeded()

            guard let storyPickerDelegate = storyPickerDelegate else {
                printErr("storyPickerDelegate isn't set")

                return
            }

            storyPickerDelegate.pickerPositionChanged(collectionViewBottomConstraint.constant)
        }
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            invalidatePickerPresentation()
            selectClosestCell()
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        invalidatePickerPresentation()
        selectClosestCell()
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        scrollAndChangeSelectionIfNeeded(to: indexPath.row)
    }

    fileprivate func scrollAndChangeSelectionIfNeeded(to idx: Int) {
        scrollToClosestCell(at: idx)

        changeSelectionIfNeeded(to: idx)
    }

    private func invalidatePickerPresentation() {
        if collectionViewBottomConstraint.constant > collectionView.height / 2 {
            changePresentation(.shown)
        } else {
            changePresentation(.hidden)
        }
    }

    private func selectClosestCell() {
        guard let closestCell = closestCell() else {
            printErr("can't get closest cell")

            return
        }

        guard let indexPath = collectionView.indexPath(for: closestCell) else {
            printErr("closest cell isn't visible")

            return
        }

        scrollAndChangeSelectionIfNeeded(to: indexPath.row)
    }

    private func scrollToClosestCell(at index: Int) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            printErr("wrong layout")

            return
        }

        let singleCellWidthWithOffset = layout.itemSize.width + layout.minimumLineSpacing

        let offsetMultiplier = max(index, 0)
        let offsetToClosestCell = singleCellWidthWithOffset * CGFloat(offsetMultiplier) - collectionView.contentInset.left

        collectionView.setContentOffset(CGPoint(x: offsetToClosestCell, y: 0), animated: true)
    }

    private func changeSelectionIfNeeded(to index: Int) {
        if index != selectedIdx {
            selectedIdx = index
        }
    }

    private func closestCell() -> UICollectionViewCell? {
        let visibleCells = collectionView.visibleCells

        // distance between at least one cell and selector always smaller, then self.width
        var smallestDistanceToSelectorView = width

        let selectorViewCenterX = selectorImageView.centerX

        var closestCell: UICollectionViewCell? = nil

        for cell in visibleCells {
            let cellCenter = cell.center

            let cellCenterXInSelf = collectionView.convert(cellCenter, to: self).x

            let distanceFromSelector = abs(cellCenterXInSelf - selectorViewCenterX)

            if smallestDistanceToSelectorView > distanceFromSelector {
                smallestDistanceToSelectorView = distanceFromSelector

                closestCell = cell
            }
        }

        return closestCell
    }
}


extension StoryPickerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let imageUrls = imageUrls else {
            printErr("no images set")

            return 0
        }

        return imageUrls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Ids.lImageCollectionViewCell, for: indexPath) as? ImageCollectionViewCell else {
            printErr("can't dequeue needed cell")

            return UICollectionViewCell()
        }

        guard let imageUrls = imageUrls, imageUrls.count > indexPath.row else {
            printErr("provided images are not enough")

            return cell
        }

        cell.charge(with: imageUrls[indexPath.row], placeholderImage: storyPickerDelegate?.placeholderImage)

        return cell
    }
}


fileprivate enum Constants {

    enum Identifiers {
        static let lImageCollectionViewCell = "lImageCollectionViewCell"
    }

}

fileprivate typealias Ids = Constants.Identifiers
