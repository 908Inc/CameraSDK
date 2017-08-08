//
//  Webservice.swift
//  Pods
//
//  Created by vlad on 4/10/17.
//
//

import UIKit

enum WebservicesError: String, Error {
    case noData = "No data received, without error"
    case unknownFormat = "Received data is in unknown format"
}

open class Webservice: NSObject {
    public init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    public let urlSession: URLSession

    public func parseResponse(_ data: Data?, error: Error?, completion: (([String: AnyHashable]?, Error?) -> ())? = nil) {
        do {
            guard error == nil else {
                completion?(nil, error)

                return
            }
            guard let data = data else {
                completion?(nil, error ?? WebservicesError.noData)

                return
            }
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyHashable] else {
                completion?(nil, error ?? WebservicesError.unknownFormat)

                return
            }

            completion?(json, nil)
        } catch {
            completion?(nil, error)
        }
    }
}
