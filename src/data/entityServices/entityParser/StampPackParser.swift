//
//  StampPackParser.swift
//  Stories
//
//  Created by vlad on 3/29/17.
//  Copyright © 2017 908. All rights reserved.
//

import UIKit

class StampPackParser: NSObject {
    func parseJsonArray(_ stampPackDicts: [[String: Any]]) throws -> Bool {
        var existedPacks = StampPack.stk_findAll() as? [StampPack] ?? [StampPack]()

        for (idx, stampPackDict) in stampPackDicts.enumerated() {
            guard let packId = stampPackDict["pack_id"] as? Int else {
                printErr("no packId provided", logToServer: true)

                continue
            }

            let updatedPack: StampPack

            if let oldPack = (existedPacks.first { $0.id == Int32(packId) }) {
                existedPacks.remove(oldPack)

                updatedPack = oldPack
            } else {
                updatedPack = StampPack.stk_object(withUniqueAttribute: "id", value: NSNumber(value: packId))
            }

            let isPackInfoTheSame = updatedPack.name == stampPackDict["pack_name"] as? String && updatedPack.title == stampPackDict["title"] as? String

            if !isPackInfoTheSame {
                updatedPack.chargeWithDict(stampPackDict)
                updatedPack.orderNumber = Int16(idx)
            }

            guard let stampDicts = stampPackDict["stamps"] as? [[String: Any]] else {
                printErr("stamp pack is empty", logToServer: true)

                continue
            }

            updateStampsFromDicts(stampDicts, for: updatedPack)
        }

        SessionManager.shared.coreDataManager.removeObjects(existedPacks)

        let hasChanges = SessionManager.shared.coreDataManager.mainContext.hasChanges

        if hasChanges {
            try SessionManager.shared.coreDataManager.mainContext.save()
        }

        return hasChanges
    }

    func updateStampsFromDicts(_ stampDicts: [[String: Any]], for pack: StampPack) {
        var existedStamps = pack.stamps?.allObjects as? [Stamp] ?? [Stamp]()

        for (idx, stampDict) in stampDicts.enumerated() {
            guard let stampId = stampDict["content_id"] as? Int else {
                printErr("no stampId provided", logToServer: true)

                continue
            }

            let updatedStamp: Stamp

            if let oldStamp = (existedStamps.first { $0.id == Int32(stampId) }) {
                existedStamps.remove(oldStamp)

                updatedStamp = oldStamp
            } else {
                updatedStamp = Stamp.stk_object(withUniqueAttribute: "id", value: NSNumber(value: stampId))
            }

            let isStampInfoTheSame = updatedStamp.name == stampDict["name"] as? String && updatedStamp.imageUrl == (stampDict["image"] as? [String: Any])?[Utility.scaleString] as? String

            if !isStampInfoTheSame {
                updatedStamp.chargeWithDict(stampDict)
                updatedStamp.pack = pack
                updatedStamp.orderNumber = Int16(idx)
            }
        }

        SessionManager.shared.coreDataManager.removeObjects(existedStamps)
    }
}


fileprivate extension StampPack {
    func chargeWithDict(_ dict: [String: Any]) {
        if let name = dict["pack_name"] as? String {
            self.name = name
        } else {
            printErr("unnamed pack")
        }

        if let title = dict["title"] as? String {
            self.title = title
        } else {
            printErr("unnamed pack")
        }
    }
}


fileprivate extension Stamp {
    func chargeWithDict(_ dict: [String: Any]) {
        if let name = dict["name"] as? String {
            self.name = name
        } else {
            printErr("stamp name is invalid")
        }

        if let imageUrl = (dict["image"] as? [String: Any])?[Utility.scaleString] as? String {
            self.imageUrl = imageUrl
        } else {
            printErr("stamp url is invalid")
        }
    }
}
