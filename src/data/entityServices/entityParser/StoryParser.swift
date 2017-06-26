//
//  StoryParser.swift
//  Stories
//
//  Created by vlad on 3/30/17.
//  Copyright © 2017 908. All rights reserved.
//

import UIKit

class StoryParser: NSObject {

    init(squareMode: Bool = false) {
        self.squareMode = squareMode
    }

    private var squareMode: Bool

    func parseJsonArray(_ storiesDicts: [[String: Any]]) throws {
        var existedStories = Story.stk_findAll() as? [Story] ?? [Story]()

        for (idx, storyDict) in storiesDicts.enumerated() {
            guard let storyId = storyDict["id"] as? Int else {
                printErr("no packId provided", logToServer: true)

                continue
            }

            let existingStory: Story

            if let oldStory = (existedStories.first { $0.id == Int32(storyId) }) {
                existedStories.remove(oldStory)

                existingStory = oldStory
            } else {
                existingStory = Story.stk_object(withUniqueAttribute: "id", value: NSNumber(value: storyId))
            }


            // update data hash is the same; no need to update
            if existingStory.dataHash == storyDict["data_hash"] as? String {
                continue
            }

            existingStory.chargeWithDict(storyDict)
            existingStory.orderNumber = Int16(idx)

            guard let storyStampDicts = storyDict["content"] as? [[String: Any]] else {
                printErr("stamp pack is empty", logToServer: true)

                continue
            }

            updateStoryStampsFromDicts(storyStampDicts, for: existingStory)
        }

        SessionManager.shared.coreDataManager.removeObjects(existedStories)

        try SessionManager.shared.coreDataManager.saveIfNeeded()
    }

    func updateStoryStampsFromDicts(_ storyStampDicts: [[String: Any]], for story: Story) {
        if let existedStamps = story.stamps?.allObjects as? [StoryStamp] {
            SessionManager.shared.coreDataManager.removeObjects(existedStamps)
        }

        for storyStampDict in storyStampDicts {
            guard let existingStoryStamp: StoryStamp = StoryStamp.insertNewObject() else {
                printErr("can't insert new stamp")

                continue
            }

            existingStoryStamp.chargeWithDictVer2(storyStampDict, squareMode: squareMode)
            existingStoryStamp.story = story
        }
    }
}


fileprivate extension Story {
    func chargeWithDict(_ dict: [String: Any]) {
        if let storyIconUrl = ((dict["icon"] as? [String: Any])?["image"] as? [String: Any])?[Utility.scaleString] as? String {
            self.iconUrl = storyIconUrl
        } else {
            printErr("no storyIconUrl provided")
        }

        if let dataHash = dict["data_hash"] as? String {
            self.dataHash = dataHash
        } else {
            printErr("no dataHash provided")
        }
    }
}


fileprivate extension StoryStamp {
    func chargeWithDict(_ dict: [String: Any], squareMode: Bool) {
        if let stampId = dict["content_id"] as? Int {
            self.id = Int32(stampId)
        } else {
            printErr("no stampId provided", logToServer: true)
        }

        if let imageUrl = (dict["image"] as? [String: Any])?[Utility.scaleString] as? String {
            self.imageUrl = imageUrl
        } else {
            printErr("no image provided")
        }

        if let orderNumber = dict["order"] as? Int {
            self.orderNumber = Int16(orderNumber)
        } else {
            printErr("stamp order is invalid")
        }

        if let pointDicts = dict["points"] as? [[String: Any]] {
            let stampPositionPointsContainer = StampPositionPointsContainer(dicts: pointDicts)

            pointsContainer = stampPositionPointsContainer
        } else {
            printErr("stamp points are invalid")
        }

        if let position = dict["position"] as? String {
            self.position = position
        } else {
            printErr("stamp position is invalid")
        }

        if let rotation = dict["rotation"] as? Float {
            self.rotation = rotation
        } else {
            self.rotation = 0.0
            printErr("stamp rotation is invalid; set to 0.0")
        }

        if let scale = dict["scale"] as? Float {
            self.scale = scale
        } else {
            self.scale = 1.0
            printErr("stamp scale is invalid; set to 1.0")
        }

        if squareMode {
            scale *= 0.6
        }

        if let type = dict["type"] as? String {
            self.type = type
        } else {
            printErr("stamp type is invalid")
        }
    }

    func chargeWithDictVer2(_ dict: [String: Any], squareMode: Bool) {
        if let stampId = dict["content_id"] as? Int {
            self.id = Int32(stampId)
        } else {
            printErr("no stampId provided", logToServer: true)
        }

        if let imageUrl = (dict["image"] as? [String: Any])?[Utility.scaleString] as? String {
            self.imageUrl = imageUrl
        } else {
            printErr("no image provided")
        }

        if let orderNumber = dict["order"] as? Int {
            self.orderNumber = Int16(orderNumber)
        } else {
            printErr("stamp order is invalid")
        }

        if let pointDicts = dict["points"] as? [[String: Any]] {
            let stampPositionPointsContainer = StampPositionPointsContainer(dicts: pointDicts)

            pointsContainer = stampPositionPointsContainer
        } else {
            printErr("stamp points are invalid")
        }

        if let position = dict["position"] as? String {
            self.position = position
        } else {
//            printErr("stamp position is invalid")
        }

        if let rotation = dict["delta_rotation"] as? Float {
            self.rotation = rotation
        } else {
            self.rotation = 0.0
        }

        if let scale = dict["delta_scale"] as? Float {
            self.scale = scale
        } else {
            self.scale = 1.0
        }

        if let deltaOffset = dict["delta_offset"] as? [String: Any] {
            offsetX = deltaOffset["x"] as? Float ?? 0
            offsetY = deltaOffset["y"] as? Float ?? 0
        } else {
            self.scale = 1.0
        }

        if squareMode {
            scale *= 0.6
        }

        if let type = dict["type"] as? String {
            self.type = type
        } else {
            printErr("stamp type is invalid")
        }
    }
}
