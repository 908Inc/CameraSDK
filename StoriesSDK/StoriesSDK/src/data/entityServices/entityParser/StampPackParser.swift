//
//  StampPackParser.swift
//  Stories
//
//  Created by vlad on 3/29/17.
//  Copyright © 2017 908. All rights reserved.
//

import UIKit

class StampPackParser: NSObject {
    func parseJsonArray(_ stampPackDicts: [[String: Any]]) throws {
        for (idx, stampPackDict) in stampPackDicts.enumerated() {
            guard let packId = stampPackDict["pack_id"] as? Int else {
                printErr("no packId provided", logToServer: true)

                continue
            }

            let existingPack = StampPack.stk_object(withUniqueAttribute: "id", value: NSNumber(value: packId))

            let isPackInfoTheSame = existingPack.name == stampPackDict["pack_name"] as? String && existingPack.title == stampPackDict["title"] as? String

            if !isPackInfoTheSame {
                existingPack.chargeWithDict(stampPackDict)
                existingPack.orderNumber = Int16(idx)
            }

            guard let stampDicts = stampPackDict["stamps"] as? [[String: Any]] else {
                printErr("stamp pack is empty", logToServer: true)

                continue
            }

            updateStampsFromDicts(stampDicts, for: existingPack)
        }

        try SessionManager.shared.coreDataManager.saveIfNeeded()
    }

    func updateStampsFromDicts(_ stampDicts: [[String: Any]], for pack: StampPack) {
        for (idx, stampDict) in stampDicts.enumerated() {
            guard let stampId = stampDict["content_id"] as? Int else {
                printErr("no stampId provided", logToServer: true)

                continue
            }

            let existingStamp = Stamp.stk_object(withUniqueAttribute: "id", value: NSNumber(value: stampId))

            let isStampInfoTheSame = existingStamp.name == stampDict["name"] as? String && existingStamp.imageUrl == (stampDict["image"] as? [String: Any])?[Utility.scaleString] as? String

            if !isStampInfoTheSame {
                existingStamp.chargeWithDict(stampDict)
                existingStamp.pack = pack
                existingStamp.orderNumber = Int16(idx)
            }
        }
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
