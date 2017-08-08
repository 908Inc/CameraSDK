//
//  StoriesEntityService.swift
//  Stories
//
//  Created by vlad on 9/29/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit

extension NSNotification.Name {
    public static let StoriesEntityServiceDidChangedStamps: NSNotification.Name = NSNotification.Name("StoriesEntityServiceDidChangedStamps")
}

class StoriesEntityService: NSObject {

    var squareMode = false

    enum StoriesEntityServiceError: String, Error {
        case noStampsParsed
        case noStampsFetched
        case incompleteData = "Received json doesn't contain essential value"
    }

    func updateStamps(completion: @escaping ((Error?, Bool) -> ())) {
        StoriesWebservices().getStampDicts { json, error in
            self.updateCurrentStore(withReceivedJson: json, error: error, usingParser: StampPackParser(), completion: completion)
        }
    }

    func updateStories(completion: @escaping ((Error?, Bool) -> ())) {
        StoriesWebservices().getStoryDicts { json, error in
            self.updateCurrentStore(withReceivedJson: json, error: error, usingParser: StoryParser(squareMode: self.squareMode), completion: completion)
        }
    }

    private func updateCurrentStore(withReceivedJson json: [String: AnyHashable]?, error: Error?, usingParser parser: Parser, completion: @escaping ((Error?, Bool) -> ())) {
        guard error == nil else {
            completion(error, false)

            return
        }
        guard let json = json else {
            printErr("unexpected condition; json is nil, error is nil", logToServer: true)

            completion(nil, false)

            return
        }
        guard let dataArray = json["data"] as? [[String: Any]], dataArray.count > 0 else {
            completion(StoriesEntityServiceError.incompleteData, false)

            return
        }

        SessionManager.shared.coreDataManager.mainContext.perform {
            do {
                let hasChanges = try parser.parseJsonArray(dataArray)
                completion(nil, hasChanges)
            } catch {
                completion(error, false)
            }
        }
    }
}


protocol Parser {
    func parseJsonArray(_ stampPackDicts: [[String: Any]]) throws -> Bool
}

extension StampPackParser: Parser {}
extension StoryParser: Parser {}
