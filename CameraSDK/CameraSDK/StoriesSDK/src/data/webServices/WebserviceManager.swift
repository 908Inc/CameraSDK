//
//  WebserviceManager.swift
//  Stories
//
//  Created by vlad on 9/29/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit

class WebserviceManager: NSObject {
    enum StampServicesError: String, Error {
        case noStampsReceived
        case invalidUrl
        case noData = "No data received, without error"
        case unknownFormat = "Received data is in unknown format"
    }

    func getStoryDicts(responseHandler: @escaping (NSDictionary?, Error?) -> ()) {
        getRawDicts(fromPath: "stories", responseHandler: responseHandler)
    }

    func getStampDicts(responseHandler: @escaping (NSDictionary?, Error?) -> ()) {
        getRawDicts(fromPath: "stamps", responseHandler: responseHandler)
    }

    private func getRawDicts(fromPath path: String, responseHandler: @escaping (NSDictionary?, Error?) -> ()) {
        var request = URLRequest.defaultRequest(forPath: path)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                guard error == nil else {
                    responseHandler(nil, error)

                    return
                }
                guard let data = data else {
                    responseHandler(nil, error ?? StampServicesError.noData)

                    return
                }
                guard let json = try JSONSerialization.jsonObject(with: data) as? NSDictionary else {
                    responseHandler(nil, error ?? StampServicesError.unknownFormat)

                    return
                }

                responseHandler(json, nil)
            } catch {
                responseHandler(nil, error)
            }
        }.resume()
    }
}
