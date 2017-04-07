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

    enum StoriesEntityServiceError: String, Error {
        case noStampsParsed
        case noStampsFetched
        case incompleteData = "Received json doesn't contain essential value"
    }

    func updateStamps(completion: @escaping ((Error?) -> ())) {
        StoriesWebservices().getStampDicts { json, error in
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
                completion(StoriesEntityServiceError.incompleteData)

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
        StoriesWebservices().getStoryDicts { json, error in
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
                completion(StoriesEntityServiceError.incompleteData)

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
}
