//
//  StickersEntityService.swift
//  Stories
//
//  Created by vlad on 9/29/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit

extension NSNotification.Name {
    public static let StickersEntityServiceDidChangedStamps: NSNotification.Name = NSNotification.Name("StickersEntityServiceDidChangedStamps")
}

class StickersEntityService: NSObject {

    enum StickersEntityServiceError: String, Error {
        case noStampsParsed
        case noStampsFetched
        case incompleteData = "Received json doesn't contain essential value"
    }

    func updateStamps(completion: @escaping ((Error?) -> ())) {
        WebserviceManager().getStampDicts { json, error in
            guard error == nil else {
                completion(error)

                return
            }
            guard let json = json else {
                printErr("unexpected condition; json is nil, error is nil", logToServer: true)

                completion(nil)

                return
            }
            guard let dataArray = json["data"] as? [[String: Any]] else {
                completion(StickersEntityServiceError.incompleteData)

                return
            }

            do {
                try StampPackParser().parseJsonArray(dataArray)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    func updateStories(completion: @escaping ((Error?) -> ())) {
        WebserviceManager().getStoryDicts { json, error in
            guard error == nil else {
                completion(error)

                return
            }
            guard let json = json else {
                printErr("unexpected condition; json is nil, error is nil", logToServer: true)

                completion(nil)

                return
            }
            guard let dataArray = json["data"] as? [[String: Any]] else {
                completion(StickersEntityServiceError.incompleteData)

                return
            }

            do {
                try StoryParser().parseJsonArray(dataArray)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

//    func loadStampPacks(completion: (([StampPack]?, Error?) -> ())?) {
//        WebserviceManager.sharedInstance().getStampPacks { stampDicts, error in
//            guard let stampDicts = stampDicts as? [[String: Any]] else {
//                completion?(nil, StickersEntityServiceError.noStampsParsed)
//
//                return
//            }
//
//            guard let entityDescription = StampPack.entityDescription() else {
//                completion?(nil, StickersEntityServiceError.noStampsParsed)
//
//                printErr("can't access entityDescription")
//
//                return
//            }
//
//            var stampPacks = [StampPack]()
//
//            let group = DispatchGroup()
//
//            for jsonDict in stampDicts {
//                guard let packId = jsonDict["pack_id"] as? Int32, let packName = jsonDict["pack_name"] as? String else {
//                    printErr("pack is invalid")
//
//                    continue
//                }
//                group.enter()
//
//                let pack = StampPack.stk_object(withUniqueAttribute: "id", value: NSNumber(value: packId))
//
//                pack.id = packId
//                pack.name = packName
//                pack.title = jsonDict["title"] as? String
//                pack.updatedAt = jsonDict["updated_at"] as? Int64 ?? 0
//
//                stampPacks.append(pack)
//
//                WebserviceManager.sharedInstance().getStamps(forPackName: packName) { packData, error in
//                    self.serializeStamps(packData?["stickers"] as? [Any], with: pack)
//                    group.leave()
//                }
//            }
//
//            group.notify(queue: DispatchQueue.main) {
//                do {
//                    try SessionManager.shared.coreDataManager.mainContext.save()
//
//                    completion?(stampPacks, error)
//                } catch {
//                    printErr("issue with core data saving", error: error)
//                    completion?(stampPacks, error)
//                }
//            }
//        }
//    }

    func fetchStamps(for tagText: String, completion: @escaping (([Stamp]?, Error?) -> ())) {
        let context = SessionManager.shared.coreDataManager.mainContext

        context.perform {
            let predicate = NSPredicate(format: "faceTag = %@", argumentArray: [tagText])

            guard let stamps = Stamp.stk_findAll(withPredicate: predicate, context: context) as? [Stamp], stamps.count > 0 else {
                DispatchQueue.main.async {
                    completion(nil, StickersEntityServiceError.noStampsFetched)
                }

                return
            }

            DispatchQueue.main.async {
                completion(stamps, nil)
            }
        }
    }

//    private func serializeStamps(_ stampDicts: [Any]?, with pack: StampPack? = nil, mergedTo existingStamps: [Stamp]? = nil, completion: (([StampObject]?, Error?) -> ())? = nil) {
//        guard let stickerDicts = stampDicts as? [[AnyHashable: Any]] else {
//            completion?(nil, StickersEntityServiceError.noStampsParsed)
//
//            return
//        }
//
//        var currentStamps = existingStamps
//
//        var stamps = [StampObject]()
//
//        var exists = false
//
//        for stickerDict in stickerDicts {
//            if var _currentStamps = currentStamps {
//                updateCurrentLoop: for existingStamp in _currentStamps {
//                    if existingStamp.isTheSameRepresentation(stickerDict) {
//                        _currentStamps.remove(existingStamp)
//
//                        if existingStamp == stickerDict {
//                            exists = true
//                            stamps.append(StampObject(stamp: existingStamp))
//                        }
//
//                        break updateCurrentLoop
//                    }
//                }
//
//                currentStamps = _currentStamps
//            }
//
//            if !exists {
//                let stampObject = StampObject(dict: stickerDict)
//
//                if let tags = (stickerDict as? [String: Any])?["tags"] as? [String] {
//                    stampObject.processTags(from: tags)
//                }
//
//                if let pack = pack {
//                    stampObject.stamp.pack = pack
//                }
//
//                stamps.append(stampObject)
//            }
//
//            exists = false
//        }
//
//        let context = SessionManager.shared.coreDataManager.mainContext
//
//        if let _currentStamps = currentStamps {
//            for existingStamp in _currentStamps {
//                context.delete(existingStamp)
//            }
//        }
//
//        if context.hasChanges {
//            do {
//                try context.save()
//
//                NotificationCenter.default.post(name: NSNotification.Name.StickersEntityServiceDidChangedStamps, object: nil)
//            } catch {
//                printErr("issue with core data saving", error: error)
//            }
//        }
//
//        completion?(stamps, nil)
//    }
}
