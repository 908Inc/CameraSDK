//
//  StampChooserDataProviderTests.swift
//  Stories
//
//  Created by vlad on 4/2/17.
//  Copyright © 2017 908. All rights reserved.
//

import XCTest
@testable import Stamps

class StampChooserDataProviderTests: XCTestCase {
    let mocStampPageDelegate = MocStampPageDelegate()
    var stampChooserCollectionView: UICollectionView!
    var sut: StampChooserDataProvider!

    override func setUp() {
        super.setUp()

        sut = StampChooserDataProvider(stampPageDelegate: mocStampPageDelegate)

        let stampChooserViewController = StampChooserViewController.storyboardController()
        _ = stampChooserViewController.view

        stampChooserCollectionView = stampChooserViewController.collectionView
        stampChooserCollectionView.dataSource = sut
    }
    
    override func tearDown() {
        super.tearDown()

        sut = nil
        stampChooserCollectionView = nil
    }

    func test_stampChooserDataProvider_returnsCorrectNumberOfSections() {
        XCTAssertEqual(stampChooserCollectionView.numberOfSections, 1)
    }

    func test_stampChooserDataProvider_returnsCorrectNumberOfItems() {
        let count = StampPack.stk_findAll()!.count

        sut.loadData()

        XCTAssertEqual(stampChooserCollectionView.numberOfItems(inSection: 0), count)
    }

    func test_stampChooserDataProvider_returnsCorrectCell() {
        guard let packs = StampPack.stk_findAll(), packs.count > 0 else {
            XCTFail("no stamp packs; can't test")
            
            return
        }
        
        sut.loadData()
        
        let cell = sut.collectionView(stampChooserCollectionView, cellForItemAt: IndexPath(row: 0, section: 0))

        XCTAssert(cell is StampPackChooserCell)
    }

//    func test_stampChooserDataProvider_callsChargeWithMethod() {
//        guard let packs = StampPack.stk_findAll() as? [StampPack], packs.count > 0 else {
//            XCTFail("no stamp packs; can't test")
//
//            return
//        }
//
//        let mocCollectionView = MocCollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
//        mocCollectionView.dataSource = sut
//        mocCollectionView.register(MocStoryChooserCell.self, forCellWithReuseIdentifier: StampChooserDataProvider.Constants.Identifiers.lStoryCell)
//
//        sut.loadData()
//
//        let checkedIndexPath = IndexPath(row: 0, section: 0)
//
//        let cell = sut.collectionView(mocCollectionView, cellForItemAt: checkedIndexPath) as! MocStoryChooserCell
//
//        guard let stampSet = packs[checkedIndexPath.row].stamps, let stampArray = Array(stampSet) as? [Stamp] else {
//            XCTFail("stamp packs are invalid; can't test")
//
//            return
//        }
//
//        XCTAssert(cell.imagesArray as? [Stamp] == stampArray)
//    }
}


extension StampChooserDataProviderTests {
    class MocCollectionView: UICollectionView {
        var cellDequeued = false

        override func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
            cellDequeued = true

            return super.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        }

    }

    class MocStoryChooserCell: StampPackChooserCell {
        var imagesArray: [ImageSourceContainer]? = nil

        override func charge(withImagesArray images: [ImageSourceContainer], delegate: StampPageViewControllerDelegate) {
            imagesArray = images
        }
    }
}


extension StampChooserDataProviderTests {
    class MocStampPageDelegate: StampPageViewControllerDelegate {
        func movingStarted(_ started: Bool) {}
        private(set) var topOffset: CGFloat = 0
        private(set) var bottomOffset: CGFloat = 0
        func storedImageLongPressed(_ storedImage: ImageSourceContainer, fromCellWith frame: CGRect) {}
        func storedImageSelected(_ storedImage: ImageSourceContainer) {}
    }
}
