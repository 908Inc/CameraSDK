//
//  WebserviceManager.swift
//  Stories
//
//  Created by vlad on 9/29/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit

class StoriesWebservices: Webservice {
    enum StampServicesError: String, Error {
        case noStampsReceived
        case invalidUrl
    }

    func getStoryDicts(responseHandler: @escaping ([String: AnyHashable]?, Error?) -> ()) {
        getRawDicts(fromPath: "new_stories", responseHandler: responseHandler)
    }

    func getStampDicts(responseHandler: @escaping ([String: AnyHashable]?, Error?) -> ()) {
        getRawDicts(fromPath: "stamps", responseHandler: responseHandler)
    }

    private func getRawDicts(fromPath path: String, responseHandler: @escaping ([String: AnyHashable]?, Error?) -> ()) {
        var request = URLRequest.defaultRequest(forPath: path)
        request.httpMethod = "GET"

        urlSession.dataTask(with: request) { data, response, error in
            self.parseResponse(data, error: error, completion: responseHandler)
        }.resume()
    }
}
