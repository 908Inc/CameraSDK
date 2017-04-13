//
//  StoryParser.swift
//  Stories
//
//  Created by vlad on 3/30/17.
//  Copyright © 2017 908. All rights reserved.
//

import UIKit

class StoryParser: NSObject {
    func parseJsonArray(_ stampPackDicts: [[String: Any]]) throws {
        var existedStories = Story.stk_findAll() as? [Story] ?? [Story]()

        for (idx, stampPackDict) in stampPackDicts.enumerated() {
            guard let storyId = stampPackDict["id"] as? Int else {
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
            if existingStory.dataHash == stampPackDict["data_hash"] as? String {
                continue
            }

            existingStory.chargeWithDict(stampPackDict)
            existingStory.orderNumber = Int16(idx)

            guard let storyStampDicts = stampPackDict["content"] as? [[String: Any]] else {
                printErr("stamp pack is empty", logToServer: true)

                continue
            }

            updateStoryStampsFromDicts(storyStampDicts, for: existingStory)
        }

        SessionManager.shared.coreDataManager.removeObjects(existedStories)

        try SessionManager.shared.coreDataManager.saveIfNeeded()
    }

    func updateStoryStampsFromDicts(_ storyStampDicts: [[String: Any]], for story: Story) {
        var existedStamps = story.stamps?.allObjects as? [StoryStamp] ?? [StoryStamp]()

        for storyStampDict in storyStampDicts {
            guard let stampId = storyStampDict["content_id"] as? Int else {
                printErr("no stampId provided", logToServer: true)

                continue
            }

            let existingStoryStamp: StoryStamp

            if let oldStamp = (existedStamps.first { $0.id == Int32(stampId) }) {
                existedStamps.remove(oldStamp)

                existingStoryStamp = oldStamp
            } else {
                existingStoryStamp = StoryStamp.stk_object(withUniqueAttribute: "id", value: NSNumber(value: stampId))
            }

            existingStoryStamp.chargeWithDict(storyStampDict)

            existingStoryStamp.story = story
        }

        SessionManager.shared.coreDataManager.removeObjects(existedStamps)
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
    func chargeWithDict(_ dict: [String: Any]) {
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

            self.pointsContainer = stampPositionPointsContainer
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

        if let type = dict["type"] as? String {
            self.type = type
        } else {
            printErr("stamp type is invalid")
        }
    }
}
