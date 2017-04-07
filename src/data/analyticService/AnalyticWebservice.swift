//
//  AnalyticWebservice.swift
//  Pods
//
//  Created by vlad on 4/6/17.
//
//

import UIKit
import Foundation

class AnalyticWebservice: NSObject {
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    func sendAnalytics(withDicts dicts: [[String: AnyHashable]], responseHandler: (([String: AnyHashable]?, Error?)->())? = nil) {
        do {
            let data = try JSONSerialization.data(withJSONObject: dicts)

            var request = URLRequest.defaultRequest(forPath: "statistics")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            request.httpMethod = "POST"

            urlSession.dataTask(with: request) { data, response, error in
                do {
                    guard error == nil else {
                        responseHandler?(nil, error)

                        return
                    }
                    guard let data = data else {
                        responseHandler?(nil, error ?? WebservicesError.noData)

                        return
                    }
                    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyHashable] else {
                        responseHandler?(nil, error ?? WebservicesError.unknownFormat)

                        return
                    }

                    responseHandler?(json, nil)
                } catch {
                    responseHandler?(nil, error)
                }
            }.resume()
        } catch {
            responseHandler?(nil, error)
        }
    }


    private let urlSession: URLSession
}
