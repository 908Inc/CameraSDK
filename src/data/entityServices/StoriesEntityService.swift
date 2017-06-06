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

    func updateStamps(completion: @escaping ((Error?) -> ())) {
        StoriesWebservices().getStampDicts { json, error in
            self.updateCurrentStore(withReceivedJson: json, error: error, usingParser: StampPackParser(), completion: completion)
        }
    }

    func updateStories(completion: @escaping ((Error?) -> ())) {
        StoriesWebservices().getStoryDicts { json, error in
            self.updateCurrentStore(withReceivedJson: json, error: error, usingParser: StoryParser(squareMode: self.squareMode), completion: completion)
        }
    }

    private func updateCurrentStore(withReceivedJson json: [String: AnyHashable]?, error: Error?, usingParser parser: Parser, completion: @escaping ((Error?) -> ())) {
        guard error == nil else {
            completion(error)

            return
        }
        guard let json = json else {
            printErr("unexpected condition; json is nil, error is nil", logToServer: true)

            completion(nil)

            return
        }
        guard let dataArray = json["data"] as? [[String: Any]], dataArray.count > 0 else {
            completion(StoriesEntityServiceError.incompleteData)

            return
        }

        SessionManager.shared.coreDataManager.mainContext.perform {
            do {
                try parser.parseJsonArray(dataArray)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}


protocol Parser {
    func parseJsonArray(_ stampPackDicts: [[String: Any]]) throws
}

extension StampPackParser: Parser {}
extension StoryParser: Parser {}
