//
//  StampChooserViewController.swift
//  Stories
//
//  Created by vlad on 8/17/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit

protocol StampInteractionDelegate: class {
    func stampLongPressed(_ stamp: Stamp, fromCellWith frame: CGRect)
    func stampSelected(_ stamp: Stamp)
}

protocol StoredImageInteractionDelegate: class {
    func storedImageLongPressed(_ storedImage: ImageSourceContainer, fromCellWith frame: CGRect)
    func storedImageSelected(_ storedImage: ImageSourceContainer)
}

protocol StampPageViewControllerDelegate: StoredImageInteractionDelegate {
    func movingStarted(_ started: Bool)
    var topOffset: CGFloat { get }
    var bottomOffset: CGFloat { get }
}

class StampChooserViewController: UIViewController, StampPageViewControllerDelegate {
    var delegate: StampInteractionDelegate?

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet fileprivate weak var pageIndicator: UIPageControl!

    fileprivate var selectedIdx = 0 {
        didSet {
            pageIndicator.currentPage = selectedIdx
        }
    }

    private let defaultCollectionViewBackgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.6)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = defaultCollectionViewBackgroundColor

        stampChooserDataProvider.loadData()
        pageIndicator.numberOfPages = stampChooserDataProvider.collectionView(collectionView, numberOfItemsInSection: 0)
    }

    @IBAction private func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func pageIndexChanged(_ sender: UIPageControl) {
        collectionView.setContentOffset(CGPoint(x: CGFloat(sender.currentPage) * collectionView.width, y: collectionView.contentOffset.y), animated: true)
    }


    // MARK: StampPageViewControllerDelegate

    func storedImageLongPressed(_ storedImage: ImageSourceContainer, fromCellWith frame: CGRect) {
        guard let delegate = delegate else {
            printErr("delegate is nil")

            return
        }

        guard let stamp = storedImage as? Stamp else {
            printErr("unknown storedImage object received")

            return
        }

        delegate.stampLongPressed(stamp, fromCellWith: frame)
    }

    func storedImageSelected(_ storedImage: ImageSourceContainer) {
        guard let delegate = delegate else {
            printErr("delegate is nil")

            return
        }

        guard let stamp = storedImage as? Stamp else {
            printErr("unknown storedImage object received")

            return
        }

        delegate.stampSelected(stamp)
    }

    var topOffset: CGFloat { return closeButton.bottom }

    var bottomOffset: CGFloat { return view.height - pageIndicator.top }

    func movingStarted(_ started: Bool) {
        if started {
            view.backgroundColor = UIColor.clear
        } else {
            view.backgroundColor = defaultCollectionViewBackgroundColor
        }
    }


    lazy private var stampChooserDataProvider: StampChooserDataProvider = {
        let stampChooserDataProvider = StampChooserDataProvider(stampPageDelegate: self)
        self.collectionView.dataSource = stampChooserDataProvider
        return stampChooserDataProvider
    }()
}


extension StampChooserViewController: UICollectionViewDelegate {
    private func invalidatePageIndex() {
        pageIndicator.currentPage = Int(round(collectionView.contentOffset.x / collectionView.width))
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        invalidatePageIndex()
    }
}


extension StampChooserViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = view.size
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets()
        }

        return view.size
    }
}
