//
//  StampChooserDataProvider.swift
//  Stories
//
//  Created by vlad on 4/2/17.
//  Copyright © 2017 908. All rights reserved.
//

import UIKit

class StampChooserDataProvider: NSObject {
    init(stampPageDelegate: StampPageViewControllerDelegate) {
        self.stampPageDelegate = stampPageDelegate

        super.init()
    }

    func loadData() {
        let defaultSortDescriptor = NSSortDescriptor(key: #keyPath(StampPack.orderNumber), ascending: true)

        guard let packs = StampPack.stk_findAll(sortDescriptors: [defaultSortDescriptor]) as? [StampPack], !packs.isEmpty else {
            printErr("no stamp packs found")

            return
        }

        stampPacks = packs
    }

    fileprivate var stampPacks: [StampPack]?

    fileprivate unowned let stampPageDelegate: StampPageViewControllerDelegate
}


extension StampChooserDataProvider: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stampPacks?.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Ids.lStoryCell, for: indexPath) as? StampPackChooserCell else {
            printErr("can't dequeue correct cell")

            return UICollectionViewCell()
        }

        guard let stampPacks = stampPacks else {
            printErr("stampPacks is nil")

            return UICollectionViewCell()
        }

        guard let stampSet = stampPacks[indexPath.row].stamps as? Set<Stamp> else {
            printErr("stamp set is nil")

            return UICollectionViewCell()
        }

        let sortedStamps = stampSet.sorted{ $0.orderNumber < $1.orderNumber }

        cell.charge(withImagesArray: sortedStamps, delegate: stampPageDelegate)

        return cell
    }
}


extension StampChooserDataProvider {

    enum Constants {

        enum Identifiers {
            static let lStoryCell = "lStoryCell"
        }

    }

    typealias Ids = Constants.Identifiers
}
